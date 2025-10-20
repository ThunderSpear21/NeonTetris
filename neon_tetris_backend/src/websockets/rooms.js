import { broadcastToRoom } from "./broadcaster.js";

export const rooms = new Map();

export function joinRoom(ws, { roomCode, userId }) {
  if (!rooms.has(roomCode)) {
    rooms.set(roomCode, new Set());
  }
  rooms.get(roomCode).add(ws);

  if (!ws.rooms) ws.rooms = new Set();
  ws.rooms.add({ roomCode, userId });

  broadcastToRoom(
    roomCode,
    {
      type: "USER_JOINED",
      payload: { userId },
    },
    ws
  );

  console.log(`👤 ${userId} joined room ${roomCode}`);
}

export function leaveRoom(ws, { roomCode, userId }) {
  if (!rooms.has(roomCode)) return;

  rooms.get(roomCode).delete(ws);

  if (ws.rooms) {
    for (const entry of ws.rooms) {
      if (entry.roomCode === roomCode && entry.userId === userId) {
        ws.rooms.delete(entry);
        break;
      }
    }
  }

  broadcastToRoom(roomCode, {
    type: "USER_LEFT",
    payload: { userId },
  });

  if (rooms.get(roomCode).size === 0) {
    rooms.delete(roomCode);
    console.log(`🗑️ Room ${roomCode} deleted (empty)`);
  }

  console.log(`👤 ${userId} left room ${roomCode}`);
}

export function getRoomUsers(roomCode) {
  return rooms.has(roomCode) ? Array.from(rooms.get(roomCode)) : [];
}
