import { asyncHandler } from "../utils/asyncHandler.js";
import { apiError } from "../utils/apiError.js";
import { GameRoom } from "../models/game_room_model.js";
import { GameState } from "../models/game_state_model.js";
import { PlayerState } from "../models/player_state_model.js";
import { User } from "../models/user_model.js";
import { apiResponse } from "../utils/apiResponse.js";
import { publish } from "../redis/publisher.js";
import { redisClient } from "../config/redis.js";
import { stopGameLoop, startGameLoop } from "../gameloop/manager.js";
const tetrominoes = ["I", "O", "T", "S", "Z", "J", "L"];

function generatePieceBag() {
  const bag = [...tetrominoes];
  for (let i = bag.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [bag[i], bag[j]] = [bag[j], bag[i]];
  }
  return bag;
}

function generatePieceQueue(count = 100) {
  const queue = [];
  while (queue.length < count) {
    queue.push(...generatePieceBag());
  }
  return queue.slice(0, count);
}

const generateRoomCode = () =>
  Array.from(
    { length: 6 },
    () => "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"[Math.floor(Math.random() * 32)]
  ).join("");

const generateUniqueRoomCode = async () => {
  let code;
  let exists = true;
  while (exists) {
    code = generateRoomCode();
    exists = await GameRoom.exists({ roomCode: code });
  }
  return code;
};

// --- Unranked Matchmaking Controllers ---

const createRoom = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const { roomSize } = req.params;

  if (!roomSize) throw new apiError(400, "Room size is required");

  const validSizes = [2, 3, 4];
  if (!validSizes.includes(Number(roomSize))) {
    throw new apiError(400, "Invalid room size");
  }

  const roomCode = await generateUniqueRoomCode();

  const room = await GameRoom.create({
    roomCode,
    maxPlayers: Number(roomSize),
    mode: "unranked",
    createdBy: userId,
  });

  const pieceQueue = generatePieceQueue(100);

  const hostPlayer = await PlayerState.create({
    user: userId,
    room: room._id,
    nextPieces: pieceQueue,
  });

  const newGameState = await GameState.create({
    room: room._id,
    players: [hostPlayer._id],
  });

  const populatedGameState = await GameState.findOne({ _id: newGameState._id }).populate({
    path: "players",
    populate: { path: "user", select: "username avatarUrl" },
  });

  const responseData = {
    ...room.toObject(),
    players: populatedGameState.players.map(p => p.user)
  };

  return res
    .status(201)
    .json(new apiResponse(201, responseData, "Unranked Room Created Successfully"));
});

const joinRoom = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const { roomCode } = req.params;

  if (!roomCode) throw new apiError(400, "Room code is required");

  const room = await GameRoom.findOne({ roomCode });
  if (!room) throw new apiError(404, "Room not found");

  const gameState = await GameState.findOne({ room: room._id });
  if (!gameState) throw new apiError(500, "Game state not found for this room");

  if (gameState.players.length >= room.maxPlayers) {
    throw new apiError(403, "Room is full");
  }
  if (room.status !== "waiting") {
    throw new apiError(403, "Game has already started or finished");
  }
  if (await PlayerState.findOne({ user: userId, room: room._id })) {
    throw new apiError(409, "You are already in this room");
  }

  const pieceQueue = generatePieceQueue(100);
  const player = await PlayerState.create({
    user: userId,
    room: room._id,
    nextPieces: pieceQueue,
  });

  gameState.players.push(player._id);
  await gameState.save();

  await publish("gameUpdates", {
    roomCode,
    message: {
      type: "playerJoined",
      payload: {
        userId,
        username: req.user.username,
        avatarUrl: req.user.avatarUrl,
      },
    },
  });

  const populatedGameState = await GameState.findOne({ _id: gameState._id }).populate({
    path: "players",
    populate: { path: "user", select: "username avatarUrl" },
  });

  const responseData = {
    ...room.toObject(),
    players: populatedGameState.players.map(p => p.user)
  };

  return res
    .status(200)
    .json(new apiResponse(200, responseData, "Joined room successfully"));
});

const leaveRoom = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const { roomCode } = req.params;

  const room = await GameRoom.findOne({ roomCode });
  if (!room) throw new apiError(404, "Room not found");

  const playerState = await PlayerState.findOne({
    user: userId,
    room: room._id,
  });
  if (!playerState) throw new apiError(403, "You are not in this room");

  if (String(room.createdBy) === String(userId)) {
    stopGameLoop(roomCode);
    await PlayerState.deleteMany({ room: room._id });
    await GameState.deleteOne({ room: room._id });
    await GameRoom.deleteOne({ _id: room._id });

    await publish("gameUpdates", {
      roomCode,
      message: { type: "roomClosed", payload: { roomCode } },
    });

    return res
      .status(200)
      .json(new apiResponse(200, null, "Host left, room has been closed"));
  } else {
    await GameState.updateOne(
      { room: room._id },
      { $pull: { players: playerState._id } }
    );
    await PlayerState.deleteOne({ _id: playerState._id });

    await publish("gameUpdates", {
      roomCode,
      message: {
        type: "playerLeft",
        payload: { userId },
      },
    });

    return res
      .status(200)
      .json(new apiResponse(200, null, "Successfully left the room"));
  }
});

const getRoomDetails = asyncHandler(async (req, res) => {
  const { roomCode } = req.params;

  const room = await GameRoom.findOne({ roomCode });
  if (!room) throw new apiError(404, "Room not found");

  const gameState = await GameState.findOne({ room: room._id }).populate({
    path: "players",
    populate: { path: "user", select: "username avatarUrl" },
  });

  return res
    .status(200)
    .json(new apiResponse(200, { room, gameState }, "Room details fetched"));
});

const startRoom = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const { roomCode } = req.params;

  const room = await GameRoom.findOne({ roomCode });
  if (!room) throw new apiError(404, "Room not found");

  if (String(room.createdBy) !== String(userId)) {
    throw new apiError(403, "Only the host can start the game");
  }
  if (room.status !== "waiting") {
    throw new apiError(400, "Game is not in a waiting state");
  }

  room.status = "playing";
  room.startedAt = new Date();
  await room.save();

  startGameLoop(room.roomCode, room.startedAt);

  await publish("gameUpdates", {
    roomCode,
    message: { type: "roomStarted", payload: { roomCode } },
  });

  return res
    .status(200)
    .json(new apiResponse(200, room, "Game started successfully"));
});

const finishRoom = asyncHandler(async (req, res) => {
  const { roomCode } = req.params;

  const room = await GameRoom.findOne({ roomCode });
  if (!room) throw new apiError(404, "Room not found");

  const gameState = await GameState.findOne({ room: room._id }).populate({
    path: "players",
    populate: { path: "user" },
  });
  if (!gameState) throw new apiError(404, "Game state not found");

  const bulkOperations = gameState.players.map((playerState) => {
    const statField = room.mode === "ranked" ? "rankedStats" : "unrankedStats";
    const updateOperation = {
      updateOne: {
        filter: { _id: playerState.user._id },
        update: {
          $inc: {
            [`${statField}.gamesPlayed`]: 1,
            [`${statField}.linesCleared`]: playerState.linesCleared || 0,
          },
          $max: {
            [`${statField}.highestScore`]: playerState.score || 0,
          },
        },
      },
    };
    if (playerState.placement === 1) {
      updateOperation.updateOne.update.$inc[`${statField}.gamesWon`] = 1;
    }
    return updateOperation;
  });

  if (bulkOperations.length > 0) {
    await User.bulkWrite(bulkOperations);
  }

  await publish("gameUpdates", {
    roomCode,
    message: {
      type: "gameOver",
      payload: {
        roomCode,
        results: gameState.players.map((ps) => ({
          userId: ps.user._id,
          username: ps.user.username,
          score: ps.score,
          linesCleared: ps.linesCleared,
          placement: ps.placement,
        })),
      },
    },
  });

  // Cleanup game documents from the database
  await PlayerState.deleteMany({ room: room._id });
  await GameState.deleteOne({ _id: gameState._id });
  await GameRoom.deleteOne({ _id: room._id });

  return res
    .status(200)
    .json(new apiResponse(200, null, "Room finished and stats updated"));
});

// --- Ranked Matchmaking Controllers ---

const requiredCountMap = { "2P": 2, "3P": 3, "4P": 4 };

const joinRankedQueue = asyncHandler(async (req, res) => {
  const userId = String(req.user._id);
  const { queueType } = req.params;
  if (!queueType || (!requiredCountMap[queueType] && queueType !== "quick")) {
    throw new apiError(400, "Invalid or missing queue type");
  }

  const targetQueues = queueType === "quick" ? ["2P", "3P", "4P"] : [queueType];

  for (const q of targetQueues) {
    const queueKey = `rankedQueue:${q}`;
    await redisClient.lRem(queueKey, 0, userId);
    await redisClient.lPush(queueKey, userId);
  }

  for (const q of targetQueues) {
    const queueKey = `rankedQueue:${q}`;
    const requiredCount = requiredCountMap[q];
    const queueLength = await redisClient.lLen(queueKey);

    if (queueLength >= requiredCount) {
      const playerIds = await redisClient.lRange(
        queueKey,
        0,
        requiredCount - 1
      );
      await redisClient.lTrim(queueKey, requiredCount, -1);
      for (const pid of playerIds) {
        for (const otherQueue of ["2P", "3P", "4P"]) {
          if (otherQueue !== q) {
            await redisClient.lRem(`rankedQueue:${otherQueue}`, 0, pid);
          }
        }
      }

      const roomCode = await generateUniqueRoomCode();
      const newRoom = await GameRoom.create({
        roomCode,
        mode: "ranked",
        status: "playing",
        rankedQueue: q,
        maxPlayers: requiredCount,
        startedAt: new Date(),
        createdBy: playerIds[0],
      });

      const pieceQueue = generatePieceQueue(100);
      const playerStates = await Promise.all(
        playerIds.map((id) =>
          PlayerState.create({
            room: newRoom._id,
            user: id,
            nextPieces: pieceQueue,
          })
        )
      );

      await GameState.create({
        room: newRoom._id,
        players: playerStates.map((ps) => ps._id),
      });

      startGameLoop(newRoom.roomCode, newRoom.startedAt);

      await publish("matchmaking", {
        playerIds,
        message: {
          type: "matchFound",
          payload: { roomCode, queueType: q },
        },
      });

      return res
        .status(200)
        .json(
          new apiResponse(200, { roomCode }, "Match found and room created")
        );
    }
  }

  return res
    .status(200)
    .json(new apiResponse(200, null, "Joined ranked queue, waiting for match"));
});

const leaveRankedQueue = asyncHandler(async (req, res) => {
  const userId = String(req.user._id);
  const { queueType } = req.params;

  if (!queueType) throw new apiError(400, "Queue type is required");

  const targetQueues = queueType === "quick" ? ["2P", "3P", "4P"] : [queueType];

  for (const q of targetQueues) {
    await redisClient.lRem(`rankedQueue:${q}`, 0, userId);
  }

  return res
    .status(200)
    .json(new apiResponse(200, null, "Successfully left the ranked queue"));
});

export {
  createRoom,
  joinRoom,
  leaveRoom,
  getRoomDetails,
  startRoom,
  finishRoom,
  joinRankedQueue,
  leaveRankedQueue,
};
