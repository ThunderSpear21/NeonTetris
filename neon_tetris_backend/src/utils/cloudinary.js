import { v2 as cloudinary } from "cloudinary";
import fs from "fs";
import path from "path";

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

const uploadOnCloudinary = async (filePath) => {
  try {
    if (!filePath) return null;
    const ext = path.extname(filePath).toLowerCase();
    let resourceType = null;
    if (ext === ".pdf") {
      resourceType = "raw";
    } else if ([".jpg", ".jpeg", ".png", ".webp"].includes(ext)) {
      resourceType = "image";
    } else {
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
      throw new Error(
        "Unsupported file type. Only images and PDFs are allowed."
      );
    }
    const res = await cloudinary.uploader.upload(filePath, {
      resource_type: resourceType,
      type: "upload",
    });

    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    return res;
  } catch (error) {
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
    throw error;
  }
};

const deleteFromCloudinary = async (cloudinaryUrl) => {
  try {
    const fileName = cloudinaryUrl.substring(
      cloudinaryUrl.lastIndexOf("/") + 1
    );
    let resourceType = cloudinaryUrl.includes(".pdf") ? "raw" : "image";
    let publicId = fileName;
    if (resourceType === "image") publicId = fileName.split(".")[0];
    const result = await cloudinary.uploader.destroy(publicId, {
      resource_type: resourceType,
    });
  } catch (error) {
    console.error("Error deleting from Cloudinary:", error);
    throw error;
  }
};

export { uploadOnCloudinary, deleteFromCloudinary };