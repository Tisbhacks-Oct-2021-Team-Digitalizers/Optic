import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_to_speech/text_to_speech.dart';

final textToSpeechServiceProvider = Provider((ref) {
  final TextToSpeech tts = TextToSpeech();
  //final String lang = 'en-US';
  //final double volume = 1;
  //final double rate = 1;
  //final double pitch = 1;
  //tts.setLanguage(lang);
  //tts.setPitch(pitch);
  //tts.setRate(rate);
  //tts.setVolume(volume);
  // call all the textToSpeech.setPitch, setLanguage here
  return tts;
});
