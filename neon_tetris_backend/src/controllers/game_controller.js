import { asyncHandler } from "../utils/asyncHandler.js";
import { apiError } from "../utils/apiError.js";
import { GameRoom } from "../models/game_room_model.js";
import { GameState } from "../models/game_state_model.js";
import { PlayerState } from "../models/player_state_model.js";
import { User } from "../models/user_model.js";
import { apiResponse } from "../utils/apiResponse.js";
import { publish } from "../redis/publisher.js";
import { stopGameLoop } from "../gameloop/manager.js";

const getGameState = asyncHandler(async (req, res) => {
  const { roomCode } = req.params;
  const userId = req.user._id;

  const room = await GameRoom.findOne({ roomCode });
  if (!room) throw new apiError(404, "Game room not found");

  const gameState = await GameState.findOne({ room: room._id });
  if (!gameState) throw new apiError(404, "Game state not found");

  const playerState = await PlayerState.findOne({
    user: userId,
    room: room._id,
  });
  if (!playerState)
    throw new apiError(403, "You are not a player in this game");

  const opponentStates = await PlayerState.find({
    room: room._id,
    user: { $ne: userId },
  }).populate("user", "username avatarUrl");

  const initialPieces = playerState.nextPieces.slice(0, 2);

  const responseData = {
    pieces: initialPieces,
    opponents: opponentStates.map((p) => p.user),
  };

  return res
    .status(200)
    .json(new apiResponse(200, responseData, "Initial game state fetched"));
});


const reportAction = asyncHandler(async (req, res) => {
  const { roomCode } = req.params;
  const userId = req.user._id;
  const { linesCleared, scoreGained, garbageSent } = req.body;

  const room = await GameRoom.findOne({ roomCode: roomCode });
  if (!room) throw new apiError(404, "Game room not found");
  const playerState = await PlayerState.findOne({
    user: userId,
    room: room._id,
  });
  if (!playerState)
    throw new apiError(403, "You are not a player in this game");
  if (!playerState.isAlive) throw new apiError(400, "You have been eliminated");

  playerState.score += scoreGained || 0;
  playerState.linesCleared += linesCleared || 0;
  playerState.pieceIndex += 1;
  await playerState.save();

  await publish("gameUpdates", {
    roomCode,
    message: {
      type: "playerScoreUpdated",
      payload: {
        userId,
        newScore: playerState.score,
        linesCleared: playerState.linesCleared,
      },
    },
  });

  if (garbageSent > 0) {
    await publish("gameUpdates", {
      roomCode,
      message: {
        type: "garbageReceived",
        payload: {
          lines: garbageSent,
          fromPlayerId: userId,
        },
      },
    });
  }

  const nextPieceIndex = playerState.pieceIndex;
  const nextPieces = playerState.nextPieces.slice(
    nextPieceIndex,
    nextPieceIndex + 2
  );

  return res
    .status(200)
    .json(new apiResponse(200, { nextPieces }, "Action reported successfully"));
});

const getSortedStandings = async (roomId) => {
  const playerStates = await PlayerState.find({ room: roomId }).populate(
    "user",
    "username avatarUrl"
  );

  playerStates.sort((a, b) => b.score - a.score);

  return playerStates.map((ps, index) => ({
    userId: ps.user._id,
    username: ps.user.username,
    avatarUrl: ps.user.avatarUrl,
    score: ps.score,
    placement: index + 1,
    isAlive: ps.isAlive,
  }));
};


const playerGameOver = asyncHandler(async (req, res) => {
  const { roomCode } = req.params;
  const userId = req.user._id;

  const room = await GameRoom.findOne({ roomCode });
  if (!room) throw new apiError(404, "Game room not found");

  const playerState = await PlayerState.findOne({
    user: userId,
    room: room._id,
  });
  if (!playerState || !playerState.isAlive) {
    return res
      .status(200)
      .json(new apiResponse(200, null, "Player already eliminated"));
  }

  playerState.isAlive = false;
  await playerState.save();

  const allPlayerStates = await PlayerState.find({ room: room._id }).populate(
    "user",
    "username avatarUrl"
  );
  allPlayerStates.sort((a, b) => b.score - a.score);
  allPlayerStates.forEach((pState, index) => {
    pState.placement = index + 1;
  });

  await Promise.all(
    allPlayerStates.map((pState) =>
      PlayerState.updateOne(
        { _id: pState._id },
        { $set: { placement: pState.placement } }
      )
    )
  );

  await publish("gameUpdates", {
    roomCode,
    message: { type: "playerDefeated", payload: { userId: String(userId) } },
  });

  const alivePlayerCount = allPlayerStates.filter((p) => p.isAlive).length;

  if (alivePlayerCount <= 1) {
    stopGameLoop(roomCode);
    const bulkOperations = allPlayerStates

      .filter((ps) => ps && ps.user)

      .map((ps) => {
        const statField =
          room.mode === "ranked" ? "rankedStats" : "unrankedStats";

        const updateOp = {
          updateOne: {
            filter: { _id: ps.user._id },

            update: {
              $inc: {
                [`${statField}.gamesPlayed`]: 1,

                [`${statField}.linesCleared`]: ps.linesCleared || 0,
              },

              $max: { [`${statField}.highestScore`]: ps.score || 0 },
            },
          },
        };
        if (ps.placement === 1) {
          updateOp.updateOne.update.$inc[`${statField}.gamesWon`] = 1;
        }

        return updateOp;
      });
    if (bulkOperations.length > 0) await User.bulkWrite(bulkOperations);

    await publish("gameUpdates", {
      roomCode,
      playerIdsToBroadcast: allPlayerStates.map((p) => p.user._id.toString()),
      message: {
        type: "gameOver",
        payload: {
          results: allPlayerStates
            .filter((ps) => ps.user)
            .map((ps) => ({
              userId: ps.user._id,
              username: ps.user.username,
              score: ps.score,
              placement: ps.placement,
            }))
            .sort((a, b) => a.placement - b.placement),
        },
      },
    });

    await PlayerState.deleteMany({ room: room._id });
    await GameState.deleteOne({ room: room._id });
    await GameRoom.deleteOne({ _id: room._id });
  }

  const finalStandings = await PlayerState.find({ room: room._id })
    .populate("user", "username")
    .sort({ placement: 1 });

  const responseData = finalStandings.map((p) => ({
    username: p.user.username,
    score: p.score,
    placement: p.placement,
    isAlive: p.isAlive,
  }));

  return res
    .status(200)
    .json(
      new apiResponse(
        200,
        { standings: responseData },
        "You have been eliminated."
      )
    );
});

const getStandings = asyncHandler(async (req, res) => {
  const { roomCode } = req.params;
  const room = await GameRoom.findOne({ roomCode });
  if (!room) throw new apiError(404, "Game room not found");

  const standings = await getSortedStandings(room._id);
  return res
    .status(200)
    .json(new apiResponse(200, { standings }, "Standings fetched"));
});

export { getGameState, reportAction, playerGameOver, getStandings };
