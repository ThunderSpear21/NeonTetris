import { createClient } from "redis";

export const redisClient = createClient({
  url: process.env.REDIS_URL || "redis://localhost:6379",
});
export const redisSubscriber = redisClient.duplicate();
redisClient.on("error", (err) => console.error("❌ Redis Error:", err));
redisSubscriber.on("error", (err) =>
  console.error("❌ Redis Subscriber Error:", err)
);

export async function initRedis() {
  await Promise.all([redisClient.connect(), redisSubscriber.connect()]);
  console.log("✅ Redis clients connected");
}
