import mongoose from "mongoose";

const gameRoomSchema = new mongoose.Schema(
  {
    roomCode: {
      type: String,
      required: true,
      unique: true,
    },
    mode: {
      type: String,
      enum: ["ranked", "unranked"],
      required: true,
    },
    rankedQueue: {
      type: String,
      enum: ["2P", "3P", "4P", "quick"],
      default: null,
    },
    status: {
      type: String,
      enum: ["waiting", "playing", "finished"],
      default: "waiting",
    },
    maxPlayers: {
      type: Number,
      required: true,
    },
    startedAt: {
      type: Date,
      default: null,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  { timestamps: true }
);

export const GameRoom = mongoose.model("GameRoom", gameRoomSchema);
