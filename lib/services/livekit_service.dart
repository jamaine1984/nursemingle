import 'package:livekit_client/livekit_client.dart';
import '../utils/api_service.dart';

class LiveKitService {
  static LiveKitService? _instance;
  
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  LocalParticipant? get localParticipant => _room?.localParticipant;
  
  LiveKitService._internal();
  
  factory LiveKitService() {
    _instance ??= LiveKitService._internal();
    return _instance!;
  }

  Room? get room => _room;

  Future<bool> connect({
    required String roomName,
    required String participantName,
    required String participantId,
  }) async {
    try {
      // Get LiveKit token from backend
      final tokenResponse = await ApiService.getLiveKitToken(roomName);
      
      if (tokenResponse['token'] == null) {
        print('LiveKit: Failed to get token from backend');
        return false;
      }

      final token = tokenResponse['token'] as String;
      final url = tokenResponse['url'] ?? 'wss://nurse-mingle.com';

      // Connect to LiveKit room
      _room = Room();
      _listener = _room!.createListener();
      
      await _room!.connect(
        url,
        token,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: AudioPublishOptions(
            dtx: true,
          ),
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: true,
          ),
        ),
      );

      // Set up event listeners
      _setupEventListeners();
      
      print('LiveKit: Connected to room $roomName as $participantName');
      return true;
    } catch (e) {
      print('LiveKit connection error: $e');
      return false;
    }
  }

  Future<bool> startLiveStream({
    required String title,
    required String description,
    String? category,
  }) async {
    try {
      // Create live stream on backend
      final response = await ApiService.post('/live/start', {
        'title': title,
        'description': description,
        'category': category ?? 'general',
      });

      if (response['success'] == true && response['room'] != null) {
        final roomName = response['room']['name'];
        final participantName = response['user']['name'] ?? 'Host';
        final participantId = response['user']['id'];

        // Connect to the LiveKit room
        return await connect(
          roomName: roomName,
          participantName: participantName,
          participantId: participantId,
        );
      }

      return false;
    } catch (e) {
      print('LiveKit start stream error: $e');
      return false;
    }
  }

  Future<bool> joinLiveStream(String streamId) async {
    try {
      // Get room info from backend
      final response = await ApiService.get('/live/room', queryParams: {'id': streamId});

      if (response['success'] == true && response['room'] != null) {
        final roomName = response['room']['name'];
        final participantName = response['user']['name'] ?? 'Viewer';
        final participantId = response['user']['id'];

        // Connect to the LiveKit room
        return await connect(
          roomName: roomName,
          participantName: participantName,
          participantId: participantId,
        );
      }

      return false;
    } catch (e) {
      print('LiveKit join stream error: $e');
      return false;
    }
  }

  void _setupEventListeners() {
    _listener?.on<ParticipantConnectedEvent>((event) {
      print('Participant connected: ${event.participant.identity}');
    });

    _listener?.on<ParticipantDisconnectedEvent>((event) {
      print('Participant disconnected: ${event.participant.identity}');
    });

    _listener?.on<LocalTrackPublishedEvent>((event) {
      print('Local track published: ${event.publication.source}');
    });

    _listener?.on<TrackSubscribedEvent>((event) {
      print('Track subscribed: ${event.publication.source}');
    });
  }

  Future<void> disconnect() async {
    try {
      await _room?.disconnect();
      await _room?.dispose();
      _room = null;
      _listener = null;
      print('LiveKit: Disconnected from room');
    } catch (e) {
      print('LiveKit disconnect error: $e');
    }
  }

  Future<bool> enableCamera() async {
    try {
      await _room?.localParticipant?.setCameraEnabled(true);
      print('LiveKit: Camera enabled');
      return true;
    } catch (e) {
      print('LiveKit camera error: $e');
      return false;
    }
  }

  Future<bool> disableCamera() async {
    try {
      await _room?.localParticipant?.setCameraEnabled(false);
      print('LiveKit: Camera disabled');
      return true;
    } catch (e) {
      print('LiveKit camera error: $e');
      return false;
    }
  }

  Future<bool> enableMicrophone() async {
    try {
      await _room?.localParticipant?.setMicrophoneEnabled(true);
      print('LiveKit: Microphone enabled');
      return true;
    } catch (e) {
      print('LiveKit microphone error: $e');
      return false;
    }
  }

  Future<bool> disableMicrophone() async {
    try {
      await _room?.localParticipant?.setMicrophoneEnabled(false);
      print('LiveKit: Microphone disabled');
      return true;
    } catch (e) {
      print('LiveKit microphone error: $e');
      return false;
    }
  }

  Future<void> switchCamera() async {
    try {
      final localVideo = _room?.localParticipant?.videoTrackPublications.firstOrNull;
      if (localVideo?.track != null) {
        final videoTrack = localVideo!.track as LocalVideoTrack;
        // Get current camera position
        await videoTrack.switchCamera('user');
        print('LiveKit: Camera switched');
      }
    } catch (e) {
      print('LiveKit switch camera error: $e');
    }
  }

  Future<void> toggleScreenShare() async {
    try {
      if (_room?.localParticipant?.isScreenShareEnabled() ?? false) {
        await _room?.localParticipant?.setScreenShareEnabled(false);
      } else {
        await _room?.localParticipant?.setScreenShareEnabled(true);
      }
    } catch (e) {
      print('LiveKit screen share error: $e');
    }
  }

  int get viewerCount {
    return _room?.remoteParticipants.length ?? 0;
  }

  List<RemoteParticipant> get remoteParticipants {
    return _room?.remoteParticipants.values.toList() ?? [];
  }

  // Store the token for later use
  Future<void> saveToken(String token) async {
    // You can store the token in SharedPreferences if needed
  }

  Future<String?> getToken() async {
    // Retrieve stored token if needed
    return null;
  }

  void dispose() {
    disconnect();
  }
} 
