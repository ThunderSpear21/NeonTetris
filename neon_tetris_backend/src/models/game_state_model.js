import mongoose from "mongoose";

const gameStateSchema = new mongoose.Schema(
  {
    room: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "GameRoom",
      required: true,
    },
    players: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "PlayerState",
      },
    ],
    isPaused: {
      type: Boolean,
      default: false,
    },
    tick: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
);

export const GameState = mongoose.model("GameState", gameStateSchema);
