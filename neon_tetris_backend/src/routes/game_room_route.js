import { Router } from "express";
import {
  createRoom,
  joinRoom,
  leaveRoom,
  getRoomDetails,
  startRoom,
  finishRoom,
  joinRankedQueue,
  leaveRankedQueue,
} from "../controllers/game_room_controller.js";
import { verifyJWT } from "../middlewares/auth_middleware.js";

const router = Router();
router.use(verifyJWT);

router.route("/create/:roomSize").post(createRoom);

router.route("/join/:roomCode").post(joinRoom);

router.route("/leave/:roomCode").post(leaveRoom);

router.route("/ranked/join/:queueType").post(joinRankedQueue);

router.route("/ranked/leave/:queueType").post(leaveRankedQueue);

router.route("/get/:roomCode").get(getRoomDetails);

router.route("/start/:roomCode").post(startRoom);

router.route("/finish/:roomCode").post(finishRoom);

export default router;
