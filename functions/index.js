const functions = require('firebase-functions');
const { AccessToken } = require('livekit-server-sdk');

exports.generateLiveKitToken = functions.https.onCall((data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  const { roomName, userId } = data;
  if (!roomName || !userId) {
    throw new functions.https.HttpsError('invalid-argument', 'roomName and userId are required.');
  }

  try {
    const apiKey = 'API28ejikL3WVsA'; // LiveKit API Key from env
    const apiSecret = 'wt7VoWbUM1plxEq18rGRdHokirc0yfDGeid1qKWO2zy'; // LiveKit API Secret

    const at = new AccessToken(apiKey, apiSecret, {
      identity: userId,
      name: context.auth.token.name || userId,
    });

    at.addGrant({
      roomJoin: true,
      room: roomName,
      canPublish: true,
      canSubscribe: true,
    });

    const token = at.toJwt();
    return { token };
  } catch (error) {
    console.error('Error generating token:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate token.');
  }
});