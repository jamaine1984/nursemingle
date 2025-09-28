import { useEffect, useRef, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Room } from 'livekit-client';
import { VideoTrack } from '@livekit/components-react';
import { Heart } from 'lucide-react';
import { liveKitService, authService } from '../services/authService';

const VideoCall = () => {
  const navigate = useNavigate();
  const { roomName } = useParams<{ roomName: string }>();
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState('');
  const roomRef = useRef(null);
  const [room, setRoom] = useState(null);
  const [participants, setParticipants] = useState([]);

  const connectToRoom = async () => {
    try {
      if (!roomName) {
        setError('No room name provided');
        return;
      }

      const token = await liveKitService.generateToken(roomName);

      const newRoom = new Room();
      await newRoom.connect('wss://nursemingle-9kc9a8ca.livekit.cloud', token);

      newRoom.on('participantConnected', () => {
        setParticipants(newRoom.participants ? Object.values(newRoom.participants) : []);
      });

      newRoom.on('participantDisconnected', () => {
        setParticipants(newRoom.participants ? Object.values(newRoom.participants) : []);
      });

      roomRef.current = newRoom;
      setRoom(newRoom);
      setIsConnected(true);
      setError('');
    } catch (error) {
      console.error('Failed to connect to room:', error);
      setError('Failed to start video call. Please try again.');
    }
  };

  const disconnectFromRoom = () => {
    if (roomRef.current) {
      roomRef.current.disconnect();
    }
    setIsConnected(false);
    setRoom(null);
    setParticipants([]);
    navigate('/home');
  };

  useEffect(() => {
    const currentUser = authService.getCurrentUser();
    if (roomName && currentUser) {
      connectToRoom();
    } else if (!currentUser) {
      navigate('/auth');
    }

    return () => {
      if (roomRef.current) {
        roomRef.current.disconnect();
      }
    };
  }, [roomName, navigate]);

  return (
    <div className="video-call bg-gradient-to-br from-pink-400 to-blue-500 min-h-screen p-4">
      <div className="max-w-6xl mx-auto">
        <div className="bg-white rounded-2xl shadow-xl p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl font-bold text-gray-800">Video Call</h2>
            <button
              onClick={disconnectFromRoom}
              className="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 transition-colors"
            >
              End Call
            </button>
          </div>

          {error && (
            <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg mb-6">
              {error}
            </div>
          )}

          {isConnected ? (
            <div>
              <div className="text-green-600 text-lg font-semibold mb-4">
                ✅ Connected to video call room: {roomName}
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                {participants.map((participant) => (
                  <div key={participant.identity} className="bg-gray-100 rounded-lg p-4">
                    <div className="text-sm font-medium text-gray-700 mb-2">
                      {participant.identity === authService.getCurrentUser()?.uid ? 'You' : participant.name || 'Partner'}
                    </div>
                    <div className="bg-black rounded-lg h-64 flex items-center justify-center text-white">
                      {participant.videoTracks.size > 0 ? (
                        <VideoTrack
                          participant={participant}
                          className="w-full h-full rounded-lg"
                        />
                      ) : (
                        <div className="text-center">
                          <div className="w-16 h-16 bg-gray-500 rounded-full mx-auto mb-2 flex items-center justify-center">
                            <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                              <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                            </svg>
                          </div>
                          <p className="text-sm">{participant.identity === authService.getCurrentUser()?.uid ? 'Camera off' : 'Partner camera off'}</p>
                        </div>
                      )}
                    </div>
                    {participant.audioTracks.size > 0 && (
                      <div className="text-sm text-gray-600 mt-2">
                        <div className="flex items-center">
                          <div className="w-2 h-2 bg-green-500 rounded-full mr-2" />
                          Audio connected
                        </div>
                      </div>
                    )}
                  </div>
                ))}
              </div>

              <div className="mt-6 flex items-center justify-center">
                <div className="bg-pink-100 px-4 py-2 rounded-lg flex items-center">
                  <Heart className="w-5 h-5 text-pink-600 mr-2" />
                  <span className="text-pink-700">Deepening your connection...</span>
                </div>
              </div>
            </div>
          ) : (
            <div className="text-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-pink-600 mx-auto mb-4" />
              <p className="text-xl text-gray-600">Starting video call in room: {roomName}...</p>
              <p className="text-gray-500 mt-2">Please wait while we establish the connection</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default VideoCall;