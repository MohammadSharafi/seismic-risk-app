// import 'dart:convert';
// import 'dart:html';
//
// import 'package:anna_app/chatBot/presentation/chatBot/controllers/voice_animation_notifier.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:microphone/microphone.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import '../model/sensitive.dart';
//
//
//
// class RecorderController with ChangeNotifier {
//
// late MicrophoneRecorder _recorder;
//  AudioPlayer _audioPlayer = AudioPlayer();
//
//   RecorderController(){
//     _initRecorder();
//   }
//
//   void _initRecorder() {
//     _recorder =  MicrophoneRecorder()
//       ..init()
//       ..addListener(() {});
//   }
//
//
//
//
//  @override
//  void dispose() {
//    _recorder.dispose();
//    _audioPlayer.dispose();
//
//    super.dispose();
//  }
//
//
//  Future<void> startRecord() async {
//
//     _recorder.start();
//  }
//  Future<String?> stopRecord() async {
//    _recorder.stop();
//    notifyListeners();
//    await Future.delayed(Duration.zero);
//    String ? data=null;
//    if(_recorder.value.stopped) {
//      data = await _AudioToTextOpenAI(_recorder.value);
//      }
//    _initRecorder();
//    return data;
//  }
//
//  Future<void> play(url,voiceAnimationNotifier) async {
//
//      await _audioPlayer.setUrl(url);
//      await _audioPlayer.play();
//      // Wait for the audio to finish playing
//      await _audioPlayer.playerStateStream.firstWhere((state) => state.processingState == ProcessingState.completed);
//
//      // Perform action after audio has finished playing
//      voiceAnimationNotifier.restart();
//  }
//
//
// Future<List<int>> fetchBlob(String url) async {
//   final response = await Dio().get<List<int>>(
//     url,
//     options: Options(responseType: ResponseType.bytes),
//   );
//   return response.data!;
// }
// Future<String?> _AudioToTextOpenAI(value) async {
//   final apiKey = Sensetive().AI_TOKEN;
//   final filePath = value.recording!.url;
//
//   if (filePath.isEmpty) {
//     print('Audio file path is empty.');
//     return  null;
//   }
//
//   try {
//     final blob = await fetchBlob(filePath);
//     final formData = FormData.fromMap({
//       'file': MultipartFile.fromBytes(blob, filename: 'audio.mp3'),
//       'model': 'whisper-1',
//     });
//
//     final response = await Dio().post(
//       'https://api.openai.com/v1/audio/transcriptions',
//       data: formData,
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer $apiKey',
//           'Content-Type': 'multipart/form-data',
//         },
//       ),
//     );
//
//     print('Response: ${response.data}');
//     return response.data['text'];
//   } catch (e) {
//     print('Error: $e');
//     return null;
//   }
// }
// Future<dynamic?> TextToAudioOpenAI(String value,VoiceAnimationNotifier voiceAnimationNotifier,textEditingController) async {
//   final apiKey = Sensetive().AI_TOKEN;
//   try {
//     final formData = jsonEncode({
//       'model': 'tts-1',
//       'input': value,
//       "voice": "shimmer"
//
//     });
//     final response = await Dio().post(
//       'https://api.openai.com/v1/audio/speech',
//       data: formData,
//       options: Options(
//         responseType: ResponseType.bytes,
//         headers: {
//           'Authorization': 'Bearer $apiKey',
//           'Content-Type': 'application/json',
//         },
//       ),
//     );
//     final blob = Blob([response.data]);
//     final url = Url.createObjectUrlFromBlob(blob);
//     voiceAnimationNotifier.EndVoice();
//     voiceAnimationNotifier.plyingAnimation(true);
//     await Future.delayed(Duration(milliseconds: 2000));
//     textEditingController.text=value;
//
//     await play(url,voiceAnimationNotifier);
//     voiceAnimationNotifier.voiceState=VoiceState.INIT;
//
//     return response.data;
//   } catch (e) {
//     print('Error: $e');
//     return null;
//   }
// }
//
//
//
//
// }
