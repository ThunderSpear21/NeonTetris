import { redisClient } from "../config/redis.js";

export async function publish(channel, message) {
  try {
    await redisClient.publish(channel, JSON.stringify(message));
  } catch (err) {
    console.error("Publish error:", err);
  }
}
