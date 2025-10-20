import { Router } from "express";
import {
  getGameState,
  reportAction,
  playerGameOver,
  getStandings
} from "../controllers/game_controller.js";
import { verifyJWT } from "../middlewares/auth_middleware.js";

const router = Router();
router.use(verifyJWT);

router.route("/:roomCode/state").get(getGameState);

router.route("/:roomCode/action").post(reportAction);

router.route("/:roomCode/gg").post(playerGameOver);

router.route("/:roomCode/standings").get(getStandings);

export default router;
