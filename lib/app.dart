import 'package:flutter/material.dart';

//extension
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
// import 'package:flutter_tts/flutter_tts.dart';

bool isListening = false;

class MyAppScreen extends StatelessWidget {
  const MyAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText speech;
  String promptText = "Press The Button to start Speaking";
  String speechText = '';
  String translateText = '';
  String _selectedLanguage =
      ''; // add this variable to store the selected language

  Map<String, String> _translatedTexts =
      {}; // add this map to store translated texts
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
      _translatedTexts[targetLanguage] =
          translation.text; // store translated text in map

      _selectedLanguage = targetLanguage; // update selected language
    });
  }

  // final FlutterTts _tts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech To Text App'),
        backgroundColor: Color.fromARGB(255, 73, 245, 222),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(promptText,
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.w400)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    translatePromptText(
                        promptText, 'es'); // Translate to Spanish
                  },
                  child: Text('Spanish'),
                ),
                ElevatedButton(
                  onPressed: () {
                    translatePromptText(
                        promptText, 'ja'); // Translate to Chinese
                  },
                  child: Text('Japanese (Romanji)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    translatePromptText(
                        promptText, 'id'); // Translate to Indonesian
                  },
                  child: Text('Indonesian'),
                ),
                ElevatedButton(
                  onPressed: () {
                    translatePromptText(
                        promptText, 'fr'); // Translate to French
                  },
                  child: Text('French'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.all(15.0),
              child: Text(
                _translatedTexts[_selectedLanguage] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarGlow(
              animate: isListening,
              glowColor: Colors.blue,
              child: FloatingActionButton(
                backgroundColor: Colors.lightBlue,
                child: Icon(
                  isListening ? Icons.pause : Icons.mic,
                ),
                onPressed: listenToSpeech,
              ),
            ),
          ],
        ),
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
