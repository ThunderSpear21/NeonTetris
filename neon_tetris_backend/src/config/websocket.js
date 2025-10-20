import { WebSocketServer } from "ws";
import { createClient } from "redis";
import { sendToUsers } from "../websockets/broadcaster.js";
import { GameRoom } from "../models/game_room_model.js";
import { GameState } from "../models/game_state_model.js";
import { handleMessage } from "../websockets/events.js";
import url from "url";
import jwt from "jsonwebtoken";

export const connectedUsers = new Map();

async function setupRedisListener() {
  const subscriber = createClient({ url: process.env.REDIS_URL });
  await subscriber.connect();

  console.log("✅ Redis subscriber connected");
  await subscriber.subscribe("matchmaking", (message) => {
    try {
      const data = JSON.parse(message);
      const playerIds = data.playerIds;
      const messageToSend = data.message;

      if (playerIds && messageToSend) {
        sendToUsers(playerIds, messageToSend);
      }
    } catch (e) {
      console.error("Error processing matchmaking message from Redis:", e);
    }
  });

  await subscriber.subscribe("gameUpdates", async (message) => {
    try {
      const data = JSON.parse(message);
      const { roomCode, message: messageToSend, playerIdsToBroadcast } = data;

      if (!roomCode || !messageToSend) return;

      if (playerIdsToBroadcast) {
        console.log(
          `[DEBUG] Broadcasting directly to provided list:`,
          playerIdsToBroadcast
        );
        sendToUsers(playerIdsToBroadcast, messageToSend);
      } else {
        const room = await GameRoom.findOne({ roomCode });

        if (!room) return;

        const gameState = await GameState.findOne({ room: room._id }).populate({
          path: "players",
          select: "user",
        });

        if (!gameState) return;

        const playerIds = gameState.players.map((playerState) =>
          playerState.user.toString()
        );
        sendToUsers(playerIds, messageToSend);
      }
    } catch (e) {
      console.error("Error processing gameUpdates message from Redis:", e);
    }
  });
}

export function setupWebSocket(server) {
  const wss = new WebSocketServer({ server });

  wss.on("connection", (ws, req) => {
    try {
      const parameters = url.parse(req.url, true);
      const token = parameters.query.token;

      if (!token) {
        throw new Error("Authentication token not provided.");
      }

      const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
      const userId = decoded._id;

      connectedUsers.set(String(userId), ws);
      console.log(`✅ User connected via WebSocket with DB ID: ${userId}`);

      ws.on("message", (rawMessage) => {
        handleMessage(ws, rawMessage);
      });

      ws.on("close", () => {
        connectedUsers.delete(String(userId));
        console.log(`❌ User disconnected: ${userId}`);
      });
    } catch (error) {
      console.error("WebSocket Auth Error:", error.message);
      ws.close(1008, "Invalid authentication token");
      return;
    }
  });

  setupRedisListener().catch(console.error);

  console.log("✅ WebSocket server initialized");
  return wss;
}
