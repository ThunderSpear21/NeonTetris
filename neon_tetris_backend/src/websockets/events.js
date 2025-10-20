import { joinRoom, leaveRoom } from "./rooms.js";

function handleMessage(ws, raw) {
  let data;
  try {
    data = JSON.parse(raw);
  } catch {
    return;
  }

  switch (data.event) {
    case "JOIN_ROOM":
      joinRoom(ws, data.payload);
      break;
    case "LEAVE_ROOM":
      leaveRoom(ws, data.payload);
      break;
    default:
      console.log("Unknown WS type", data.type);
  }
}

export { handleMessage };
