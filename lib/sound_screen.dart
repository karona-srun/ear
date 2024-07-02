import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class SoundScreen extends StatefulWidget {
  const SoundScreen({super.key, required this.title, required this.name});
  final String title;
  final String name;
  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  bool isEarAIWorking = false;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  String? _aacFilePath;
  String? _wavFilePath;
  String? _predicted;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _init();
  }

  Future<void> _init() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  void _startRecording() async {
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    _aacFilePath = '/storage/emulated/0/Download/$fileName';

    await _recorder.startRecorder(
      toFile: _aacFilePath,
      codec: Codec.aacMP4,
    );
    setState(() {
      _predicted = '';
      _isRecording = true;
    });
  }

  void _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    _convertToWav();
  }

  // Future<void> _convertToWav() async {
  //   final wavFileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
  //   _wavFilePath = '/storage/emulated/0/Download/$wavFileName';
  //   await _flutterFFmpeg.execute(
  //       '-i $_aacFilePath -vn -acodec pcm_s16le -ar 44100 -ac 2 $_wavFilePath');
  //   setState(() {

  //   });
  //   _uploadFile(_wavFilePath.toString());
  // }

  Future<void> _convertToWav() async {
    if (_aacFilePath == null) return;

    final wavFileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
    _wavFilePath = '/storage/emulated/0/Download/$wavFileName';

    final command =
        '-i $_aacFilePath -acodec pcm_s16le -ar 44100 -ac 2 $_wavFilePath';
    print('Executing FFmpeg command: $command');

    await _flutterFFmpeg.execute(command).then((rc) {
      print('FFmpeg process exited with rc: $rc');
      if (rc == 0) {
        print('Conversion successful');
        setState(() {
          _uploadFile(_wavFilePath!);
        });
      } else {
        print('Conversion failed');
      }
    });
  }

  Future<void> _uploadFile(String filePath) async {
    setState(() {
      isEarAIWorking = true;
    });
    var uri = Uri.parse('https://earai.0xtou.live/');
    var request = http.MultipartRequest('POST', uri)
      ..headers['accept'] = 'application/json'
      ..headers['Content-Type'] = 'multipart/form-data'
      ..files.add(await http.MultipartFile.fromPath('file', filePath,
          contentType: MediaType('audio', 'wav')));

    var response = await request.send();
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Upload successful');
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonResponse = jsonDecode(responseString);
        final predictedClass = jsonResponse['predicted_class'];
        setState(() {
          _predicted = predictedClass;
        });
        print('Upload successful. Predicted class: $predictedClass');
      }
    } else {
      if (kDebugMode) {
        print('Upload failed: ${response}');
        print('Upload failed with status: ${response.statusCode}');
      }
    }
    setState(() {
      isEarAIWorking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.normal),
        ),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Welcome back, ',
                style: TextStyle(
                  fontSize: 18, // Adjusted for subtext
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: widget.name,
                    style: TextStyle(
                      fontSize: 20, // Adjusted for subtext
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _predicted.toString() != 'null' ? 'Result: ' + _predicted.toString() : 'Result: no detected',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                isEarAIWorking ? Image.asset('assets/audio_wave.gif') : 
                IconButton(
                  icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic),
                  iconSize: 32.0,
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  _isRecording
                      ? 'Detecting...'
                      : 'Press the mic to start recording',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
