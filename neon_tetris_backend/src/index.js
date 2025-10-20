import dotenv from "dotenv";
import connectDB from "./db/index.js";
import { app } from "./app.js";
import { createServer } from "http";
import { setupWebSocket } from "./config/websocket.js";
import { initRedis } from "./config/redis.js";
import { initSubscriber } from "./redis/subscriber.js";

dotenv.config({
  path: "./.env",
});

const server = createServer(app);

await initRedis();
await initSubscriber();

setupWebSocket(server);

connectDB()
  .then(() => {
    server.on("error", (e) => {
      console.log("Error :: ", e);
    });
    server.listen(process.env.PORT || 8000, () => {
      console.log("Server is running at port : ", process.env.PORT || 8000);
    });
  })
  .catch((e) => {
    console.log("MongoDB Connection failed :: ", e);
  });
