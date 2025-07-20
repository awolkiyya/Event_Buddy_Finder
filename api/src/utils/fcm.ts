import admin from '../config/firebase';

export const sendPushNotification = async (
  token: string,
  title: string,
  body: string
) => {
  const message = {
    notification: {
      title,
      body,
    },
    token,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('✅ Push notification sent:', response);
  } catch (error) {
    console.error('❌ Failed to send push notification:', error);
  }
};
