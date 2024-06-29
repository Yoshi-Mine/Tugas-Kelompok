// import 'dart:collection';

import 'package:avatar_glow/avatar_glow.dart';
// import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:highlight_text/highlight_text.dart';
import 'package:translator/translator.dart';

bool isListening = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeechApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: Speech(),
    );
  }
}

class Speech extends StatefulWidget {
  const Speech({super.key});

  @override
  State<Speech> createState() => _SpeechState();
}

class _SpeechState extends State<Speech> {
  // LinkedHashMap<String, HighlightedWorld> highlightedWords = LinkedHashMap();

  late stt.SpeechToText speech;
  String promptText = "Press The Button to start Speaking";
  String speechText = '';
  String translateText = '';
  double confidence = 1.0;

  @override
  void initState() {
    super.initState();
    setState(() {
      speech = stt.SpeechToText();
    });
  }

  Future<void> translatePromptText(String text, String targetLanguage) async {
    final translator = GoogleTranslator();
    var translation = await translator.translate(text, to: targetLanguage);
    setState(() {
      translateText = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Center(
        child: AvatarGlow(
          // endRadius: 75,
          animate: isListening,
          glowColor: Colors.blue,
          child: FloatingActionButton(
            backgroundColor: Colors.lightBlue,
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
            ),
            onPressed: listenToSpeech,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(
              child: Text(
                "Confidence level ${(confidence * 100).toStringAsFixed(1)}%",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SingleChildScrollView(
                reverse: false,
                padding: EdgeInsets.all(30),
                child: Text(promptText,
                    style: TextStyle(
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(100.0),
            child: ElevatedButton(
              onPressed: () {
                translatePromptText(promptText, 'es'); // Translate to Spanish
              },
              child: Text('Translate to Spanish'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              translateText, // Display the translated text here

              style: TextStyle(
                fontSize: 24,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void listenToSpeech() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (val) {
          if (val.contains("notListening")) {
            setState(() => isListening = false);
          }
          print('onStatus: $val');
        },
        onError: (val) {
          setState(() => isListening = false);
          print('onError: $val');
        },
      );
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) => setState(() {
            promptText = val.recognizedWords;
            speechText = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              confidence = val.confidence;
            }
            promptText = speechText;
          }),
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }
}
