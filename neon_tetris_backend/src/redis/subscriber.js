import { redisSubscriber } from "../config/redis.js";
import { broadcastToRoom, sendToUsers } from "../websockets/broadcaster.js";

export async function initSubscriber() {
  await redisSubscriber.subscribe("gameUpdates", (rawMessage) => {
    try {
      const { roomCode, message } = JSON.parse(rawMessage);
      if (roomCode && message) {
        broadcastToRoom(roomCode, message);
      }
    } catch (err) {
      console.error("❌ Invalid gameUpdates message:", err);
    }
  });

  await redisSubscriber.subscribe("matchmaking", (rawMessage) => {
    try {
      const { playerIds, message } = JSON.parse(rawMessage);
      if (playerIds && message) {
        sendToUsers(playerIds, message);
      }
    } catch (err) {
      console.error("❌ Invalid matchmaking message:", err);
    }
  });

  console.log("✅ Redis subscriber initialized for all channels");
}