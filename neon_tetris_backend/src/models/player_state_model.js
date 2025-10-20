import mongoose from "mongoose";

const playerStateSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    room: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "GameRoom",
      required: true,
    },
    score: {
      type: Number,
      default: 0,
    },
    linesCleared: {
      type: Number,
      default: 0,
    },
    nextPieces: {
      type: [String],
      default: [],
    },
    pieceIndex: {
      type: Number,
      default: 0,
    },
    isAlive: {
      type: Boolean,
      default: true,
    },
    placement: {
      type: Number,
      default: null,
    },
  },
  { timestamps: true }
);

export const PlayerState = mongoose.model("PlayerState", playerStateSchema);
