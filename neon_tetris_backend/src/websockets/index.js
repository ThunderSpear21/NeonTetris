import { handleMessage } from "./events.js";
import { leaveRoom } from "./rooms.js";

function handleConnection(ws) {
  ws.on("message", (raw) => handleMessage(ws, raw));
  ws.on("close", () => {
    if (ws.rooms) {
      for (const { roomCode, userId } of ws.rooms) {
        leaveRoom(ws, { roomCode, userId });
      }
    }
  });
}

export { handleConnection };
