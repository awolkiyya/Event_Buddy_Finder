import * as admin from "firebase-admin";
import * as path from "path";
import * as fs from "fs";
import { config } from "./globalConfig";

try {
  const serviceAccountPath = path.resolve(config.firebaseKeyPath);

  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(`Firebase service account file not found at path: ${serviceAccountPath}`);
  }

  const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, "utf8"));

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  console.log("✅ Firebase Admin SDK initialized successfully.");

} catch (error) {
  console.error("❌ Failed to initialize Firebase Admin SDK:", error);
  // Optionally, process.exit(1); to stop the server if critical
}

export default admin;
