import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";

const app = express();

app.use(
  cors({
    origin: process.env.CORS_ORIGIN,
    credentials: true,
  })
);

app.use(express.json({ limit: "32kb" }));

app.use(express.urlencoded({ extended: true, limit: "32kb" })); 

app.use(express.static("public"));

app.use(cookieParser());

import authRouter from "./routes/auth_route.js";
import gameRoomRouter from "./routes/game_room_route.js";
import gameRouter from "./routes/game_route.js"

app.use("/api/auth", authRouter);
app.use("/api/room", gameRoomRouter);
app.use("/api/game", gameRouter);

app.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;

  res.status(statusCode).json({
    success: false,
    message: err.message || "Internal Server Error",
    errors: err.errors || [],
    data: null,
  });
});

export { app };
