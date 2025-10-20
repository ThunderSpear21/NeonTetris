import mongoose from "mongoose";
import mongooseAggregatePaginate from "mongoose-aggregate-paginate-v2";

const otpTokenSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
  },

  otp: {
    type: String,
    required: true,
  },

  createdAt: {
    type: Date,
    default: Date.now,
    expires: 300,
  },
});

otpTokenSchema.plugin(mongooseAggregatePaginate);
export const OtpToken = mongoose.model("OtpToken", otpTokenSchema);