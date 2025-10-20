import { Router } from "express";
import {
  changeCurrentPassword,
  getCurrentUser,
  loginUser,
  logoutUser,
  refreshAccessToken,
  registerUser,
  updateAccountDetails,
  getLeaderboard,
  pingServer
} from "../controllers/auth_controller.js";
import { verifyJWT } from "../middlewares/auth_middleware.js";
import { upload } from "../middlewares/multer_middleware.js";

const router = Router();

router.route("/register").post(registerUser);

router.route("/login").post(loginUser);

router.route("/logout").post(verifyJWT, logoutUser);

router.route("/refresh-token").post(refreshAccessToken);

router.route("/change-password").post(verifyJWT, changeCurrentPassword);

router.route("/get-current-user").get(verifyJWT, getCurrentUser);

router
  .route("/update-account")
  .patch(
    verifyJWT,
    upload.fields([{ name: "avatar", maxCount: 1 }]),
    updateAccountDetails
  );

router.route("/get-leaderboard").get(verifyJWT, getLeaderboard);

router.route("/ping").get(pingServer);

export default router;
