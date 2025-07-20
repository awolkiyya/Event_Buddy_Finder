import * as admin from "firebase-admin";
import * as path from "path";
import * as dotenv from "dotenv";
dotenv.config();

if (!process.env.FIREBASE_KEY_PATH) {
  throw new Error("FIREBASE_KEY_PATH is not defined in .env");
}


const serviceAccountPath = path.resolve(process.env.FIREBASE_KEY_PATH as string);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccountPath),
});

export default admin;
