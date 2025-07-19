import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class RecordVideoScreen extends StatefulWidget {
  const RecordVideoScreen({super.key});

  @override
  State<RecordVideoScreen> createState() => _RecordVideoScreenState();
}

class _RecordVideoScreenState extends State<RecordVideoScreen> {
  CameraController? _cameraController;
  VideoPlayerController? _videoController;
  XFile? _videoFile;
  bool _isRecording = false;
  bool _isCameraReady = false;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;
    _cameraController = CameraController(_cameras![0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() => _isCameraReady = true);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || _isRecording) return;
    await _cameraController!.startVideoRecording();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;
    final file = await _cameraController!.stopVideoRecording();
    setState(() {
      _isRecording = false;
      _videoFile = file;
    });
    _videoController = VideoPlayerController.file(File(file.path));
    await _videoController!.initialize();
    setState(() {});
  }

  void _reset() {
    _videoFile = null;
    _videoController?.dispose();
    _videoController = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Video')),
      body: !_isCameraReady
          ? const Center(child: CircularProgressIndicator())
          : _videoFile == null
              ? Column(
                  children: [
                    Expanded(
                      child: CameraPreview(_cameraController!),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isRecording
                              ? ElevatedButton.icon(
                                  onPressed: _stopRecording,
                                  icon: const Icon(Icons.stop),
                                  label: const Text('Stop'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                )
                              : ElevatedButton.icon(
                                  onPressed: _startRecording,
                                  icon: const Icon(Icons.fiber_manual_record),
                                  label: const Text('Record'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: _videoController == null
                          ? const Center(child: CircularProgressIndicator())
                          : AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _reset,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Re-record'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                                      // Save video as moment
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video saved as moment!')),
        );
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
} 
