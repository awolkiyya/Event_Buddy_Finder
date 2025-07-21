import dotenv from 'dotenv';

dotenv.config();

const getEnvVar = (key: string, required = true): string => {
  const value = process.env[key];
  if (required && !value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value!;
};

export const config = {
  port: parseInt(process.env.PORT || '3000'),
  mongoUri: getEnvVar('MONGO_URI'),
  jwtSecret: getEnvVar('JWT_SECRET'),
  firebaseApiKey: getEnvVar('FIREBASE_API_KEY', false), // Optional
  socketPath: process.env.SOCKET_PATH || '/socket.io',
  clientUrl: getEnvVar('CLIENT_URL'), // Added CLIENT_URL
};
