import { WebSocket } from "ws";
import { rooms } from "./rooms.js";
import { connectedUsers } from "../config/websocket.js";

function broadcastToRoom(roomCode, message, excludeWs = null) {
  const room = rooms.get(roomCode);
  if (!room) return;
  const msg = JSON.stringify(message);
  for (const ws of room) {
    if (ws.readyState === WebSocket.OPEN && ws !== excludeWs) {
      ws.send(msg);
    }
  }
}


function sendToUsers(userIds, message) {
  const msg = JSON.stringify(message);
  for (const userId of userIds) {
    const ws = connectedUsers.get(String(userId));
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(msg);
    }
  }
}

export { broadcastToRoom, sendToUsers };