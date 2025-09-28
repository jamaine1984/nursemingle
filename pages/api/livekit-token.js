import { AccessToken } from 'livekit-server-sdk';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ message: 'Method not allowed' });
    return;
  }

  const { roomName, userId } = req.body;

  try {
    const at = new AccessToken(process.env.NEXT_PUBLIC_LIVEKIT_API_KEY, process.env.SHORT_LIVEKIT_API_SECRET, {
      identity: userId,
    });

    at.addGrant({
      roomJoin: true,
      room: roomName,
      canPublish: true,
      canSubscribe: true,
    });

    const token = at.toJwt();
    res.status(200).json({ token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}