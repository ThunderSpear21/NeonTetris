import { asyncHandler } from "../utils/asyncHandler.js";
import { apiError } from "../utils/apiError.js";
import { User } from "../models/user_model.js";
import { apiResponse } from "../utils/apiResponse.js";
import jwt from "jsonwebtoken";
import { OtpToken } from "../models/otp_token_model.js";
import bcrypt from "bcrypt";
import { sendEmail } from "../utils/sendEmail.js";
import {
  deleteFromCloudinary,
  uploadOnCloudinary,
} from "../utils/cloudinary.js";

const generateAccessAndRefreshToken = async (userId) => {
  try {
    const user = await User.findById(userId);
    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    user.refreshToken = refreshToken;
    await user.save({ validateBeforeSave: false });

    return { accessToken, refreshToken };
  } catch (error) {
    throw new apiError(500, error.message);
  }
};

const registerUser = asyncHandler(async (req, res) => {
  const { username, email, password, otp } = req.body;
  if (email && !otp && !username && !password) {
    const existingUser = await User.findOne({ email });
    if (existingUser) throw new apiError(400, "User already exists");

    const existingToken = await OtpToken.findOne({ email });
    if (existingToken) await OtpToken.deleteOne({ email });

    const rawOtp = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedOtp = await bcrypt.hash(rawOtp, 10);

    await OtpToken.create({ email, otp: hashedOtp });
    console.log("sending otp");
    await sendEmail({
      to: email,
      subject: "Your OTP for NeonTetris",
      text: `Your OTP is ${rawOtp}. It will expire in 5 minutes.`,
    });
    console.log("sent otp");
    return res
      .status(200)
      .json(new apiResponse(200, null, "OTP sent successfully"));
  }

  if (email && otp && username && password) {
    const existingUser = await User.findOne({ email });
    if (existingUser) throw new apiError(400, "User already exists");

    const otpRecord = await OtpToken.findOne({ email });
    if (!otpRecord) throw new apiError(400, "OTP expired or not found");

    const isOtpValid = await bcrypt.compare(otp, otpRecord.otp);
    if (!isOtpValid) throw new apiError(400, "Invalid OTP");

    await OtpToken.deleteOne({ email });

    const user = await User.create({
      email,
      password,
      username,
    });

    const safeUser = await User.findById(user._id).select("-password");

    return res
      .status(201)
      .json(new apiResponse(201, safeUser, "User registered successfully"));
  }

  throw new apiError(400, "Invalid registration step or missing fields");
});

const loginUser = asyncHandler(async (req, res) => {
  let { email, password } = req.body;
  if (!email?.trim()) throw new apiError(400, "Email is required");
  if (!password?.trim()) throw new apiError(400, "Password is required");

  const currentUser = await User.findOne({
    $or: [{ email: email }],
  });

  if (!currentUser) throw new apiError(404, "User does not exist");

  const isPasswordValid = await currentUser.isPasswordCorrect(password);
  if (!isPasswordValid) throw new apiError(401, "Wrong Password");
  const { accessToken, refreshToken } = await generateAccessAndRefreshToken(
    currentUser._id
  );

  await User.findByIdAndUpdate(
    currentUser._id,
    {
      $set: {
        isOnline: true,
        lastLogin: new Date(),
      },
    },
    {
      new: true,
    }
  );

  const loggedInUser = await User.findById(currentUser._id).select(
    "-password -refreshToken"
  );
  const options = {
    httpOnly: true,
    secure: true,
    sameSite: "none"
  };

  return res
    .status(200)
    .cookie("accessToken", accessToken, options)
    .cookie("refreshToken", refreshToken, options)
    .json(
      new apiResponse(
        200,
        {
          user: loggedInUser,
          accessToken,
          refreshToken,
        },
        "User logged in successfully"
      )
    );
});

const logoutUser = asyncHandler(async (req, res) => {
  await User.findByIdAndUpdate(
    req.user._id,
    {
      $set: {
        refreshToken: "",
        isOnline: false,
      },
    },
    {
      new: true,
    }
  );
  const options = {
    httpOnly: true,
    secure: true,
  };
  return res
    .status(200)
    .clearCookie("accessToken", options)
    .clearCookie("refreshToken", options)
    .json(new apiResponse(200, {}, "User logged out successfully"));
});

const refreshAccessToken = asyncHandler(async (req, res) => {
  const incomingRefreshToken =
    req.cookies.refreshToken || req.body.refreshToken;
  if (!incomingRefreshToken) throw new apiError(400, "Unauthorized User");
  try {
    const decodedToken = jwt.verify(
      incomingRefreshToken,
      process.env.REFRESH_TOKEN_SECRET
    );
    if (!decodedToken) throw new apiError(400, "Unauthorized User");

    const user = await User.findById(decodedToken?._id);
    if (!user) throw new apiError(401, "Invalid Refresh Token");

    const options = {
      httpOnly: true,
      secure: true,
    };

    if (incomingRefreshToken != user?.refreshToken)
      throw new apiError(400, "Refresh Token has expired");

    const { accessToken, refreshToken } = await generateAccessAndRefreshToken(
      user._id
    );
    return res
      .status(200)
      .cookie("accessToken", accessToken, options)
      .cookie("refreshToken", refreshToken, options)
      .json(
        new apiResponse(
          200,
          { accessToken, refreshToken },
          "Access Token refreshed successfully !!"
        )
      );
  } catch (error) {
    throw new apiError(400, error?.message || "Invalid Token");
  }
});

const changeCurrentPassword = asyncHandler(async (req, res) => {
  const { oldPassword, newPassword } = req.body;
  const user = await User.findById(req.user?._id);

  if (!(await user.isPasswordCorrect(oldPassword)))
    throw new apiError(400, "Existing Password does not match !");

  user.password = newPassword;
  await user.save({ validateBeforeSave: false });

  return res
    .status(200)
    .json(new apiResponse(200, {}, "Password Changes Successfully"));
});

const getCurrentUser = asyncHandler(async (req, res) => {
  if (!req.user) throw new apiError(401, "No user signed in !!");
  const user = await User.findById(req.user?._id).select(
    "-password -refreshToken"
  );
  return res
    .status(200)
    .json(new apiResponse(200, { user }, "Current Logged In User"));
});

const updateAccountDetails = asyncHandler(async (req, res) => {
  const imagePath = req?.files?.avatar?.[0]?.path;
  if (!imagePath) throw new apiError(400, "Image required");

  try {
    const imageUrl = await uploadOnCloudinary(imagePath);
    if (!imageUrl?.url)
      throw new apiError(500, "Failed to upload image to Cloudinary");
    const oldUser = await User.findById(req.user._id);
    if (
      oldUser.avatarUrl !=
      "https://static.vecteezy.com/system/resources/previews/007/407/996/non_2x/user-icon-person-icon-client-symbol-login-head-sign-icon-design-vector.jpg"
    )
      deleteFromCloudinary(oldUser.avatarUrl);
    const user = await User.findByIdAndUpdate(
      req.user._id,
      {
        $set: {
          avatarUrl: imageUrl.url,
        },
      },
      {
        new: true,
      }
    ).select("-password");

    return res
      .status(201)
      .json(new apiResponse(201, user, "Avatar uploaded !!"));
  } catch (err) {
    throw new apiError(400, err.message || "Avatar upload failed");
  }
});

const getLeaderboard = asyncHandler(async (req, res) => {
  const leaderboard = await User.aggregate([
    {
      $sort: {
        ["rankedStats.gamesWon"]: -1,
      },
    },
    {
      $limit: 20,
    },
    {
      $project: {
        username: 1,
        avatarUrl: 1,
        gamesWon: "$rankedStats.gamesWon",
        gamesPlayed: "$rankedStats.gamesPlayed",
        highestScore: "$rankedStats.highestScore",
        _id: 0,
      },
    },
  ]);

  return res
    .status(200)
    .json(
      new apiResponse(200, leaderboard, "Leaderboard fetched successfully !!")
    );
});

const pingServer = asyncHandler(async (req, res) => {
  const testUsers = [
    {
      username: "Poseidon",
      email: "yashkshitiz21@gmail.com",
      password: "qwerty",
    },
    {
      username: "Aura Farmer",
      email: "itsmeviraj2003@gmail.com",
      password: "qwerty",
    },
    {
      username: "Visa Employee",
      email: "1akshat.tambi@gmail.com",
      password: "qwerty",
    }
  ];

  try {
    console.log("Seeding test users if they do not exist...");
    for (const testUser of testUsers) {
      const existingUser = await User.findOne({ email: testUser.email });
      if (!existingUser) {
        await User.create(testUser);
        console.log(`✅ User "${testUser.username}" created successfully.`);
      } else {
        console.log(`- User "${testUser.username}" already exists. Skipping.`);
      }
    }
  } catch (error) {
    console.error("Error during test user seeding:", error);
  }

  return res
    .status(200)
    .json(new apiResponse(200, {}, "Server up and running !"));
});

export {
  registerUser,
  loginUser,
  logoutUser,
  refreshAccessToken,
  changeCurrentPassword,
  getCurrentUser,
  updateAccountDetails,
  getLeaderboard,
  pingServer,
};
