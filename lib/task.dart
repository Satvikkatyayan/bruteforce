import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For accessing environment variables (.env)

// --- 1. QuizQuestion Model ---
// This class helps structure the data received from the Gemini API
class QuizQuestion {
  final String question;
  final Map<String, String> options;
  final String correctAnswer;

  QuizQuestion({required this.question, required this.options, required this.correctAnswer});

  // Factory constructor to create a QuizQuestion object from a JSON map
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: Map<String, String>.from(json['options'] as Map<String, dynamic>),
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}

// --- 2. tasks Widget (Name Reverted as Requested) ---
class tasks extends StatefulWidget {
  final String topic; // Topic passed from HomeScreen hotspot tap

  const tasks({Key? key, required this.topic}) : super(key: key);

  @override
  State<tasks> createState() => _tasksState();
}

class _tasksState extends State<tasks> {
  List<QuizQuestion> _questions = [];
  bool _isLoading = true; // State to show loading indicator
  String? _error; // State to show error messages
  int _currentQuestionIndex = 0; // Tracks which question is currently displayed
  String? _selectedAnswer; // Stores the user's selected option for the current question
  int _score = 0; // Tracks the points earned in the current quiz

  @override
  void initState() {
    super.initState();
    _fetchQuizQuestions(); // Start fetching questions when the screen initializes
  }

  // --- 3. Method to Fetch Quiz Questions from Gemini API ---
  Future<void> _fetchQuizQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("GEMINI_API_KEY not found in .env file or is empty.");
      }

      // *** USING gemini-2.0-flash AS REQUESTED ***
      final url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey");

      final String prompt = '''
        Generate 3 multiple-choice quiz questions about "${widget.topic}" for an environmental awareness mobile game. 
        For each question, provide:
        - The question text.
        - Exactly 4 answer options (A, B, C, D) as a JSON object where keys are "A", "B", "C", "D" and values are the option texts.
        - The letter of the correct answer (e.g., "A", "B", "C", or "D").
        
        Ensure the entire output is a JSON array of objects, like this example:
        [
          {
            "question": "What is the primary benefit of recycling aluminum cans?",
            "options": {"A": "Saves water", "B": "Reduces air pollution", "C": "Saves significant energy", "D": "Creates new jobs"},
            "correctAnswer": "C"
          },
          {
            "question": "Which material takes the longest to decompose in a landfill?",
            "options": {"A": "Paper", "B": "Plastic bottle", "C": "Banana peel", "D": "Cotton sock"},
            "correctAnswer": "B"
          }
        ]
        
        Avoid any introductory or concluding text outside the JSON array. Only provide the JSON array.
        ''';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            "temperature": 0.7,
            "maxOutputTokens": 800,
          },
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String generatedText = responseData['candidates'][0]['content']['parts'][0]['text'];
        final RegExp jsonRegex = RegExp(r'\[.*\]', dotAll: true);
        final Match? match = jsonRegex.firstMatch(generatedText);

        if (match != null) {
          final String jsonString = match.group(0)!;
          final List<dynamic> jsonList = json.decode(jsonString);
          _questions = jsonList.map((json) => QuizQuestion.fromJson(json)).toList();

          if (_questions.isEmpty) {
            throw Exception("Gemini returned an empty list of questions.");
          }
        } else {
          try {
            final List<dynamic> jsonList = json.decode(generatedText);
            _questions = jsonList.map((json) => QuizQuestion.fromJson(json)).toList();
          } catch (_) {
            throw Exception('Failed to extract and parse JSON from Gemini response: $generatedText');
          }
        }
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load quiz from Gemini API. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching quiz: $e');
      _error = 'Failed to load quiz: $e. Please check your API key, internet connection, and Gemini API status.';
      _questions = [
        QuizQuestion(
          question: "Which of these is NOT a common recyclable material for curbside pickup?",
          options: {"A": "Glass bottles", "B": "Plastic bags", "C": "Aluminum cans", "D": "Cardboard"},
          correctAnswer: "B",
        ),
        QuizQuestion(
          question: "What is the primary benefit of reducing water usage in households?",
          options: {"A": "Increases property value", "B": "Lowers utility bills and conserves resources", "C": "Makes plants grow faster", "D": "Attracts more wildlife"},
          correctAnswer: "B",
        ),
        QuizQuestion(
          question: "Which action helps promote biodiversity in urban areas?",
          options: {"A": "Paving over green spaces", "B": "Planting native species", "C": "Using synthetic pesticides", "D": "Introducing invasive plants"},
          correctAnswer: "B",
        ),
      ];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkAnswer(String selectedOption) {
    setState(() {
      _selectedAnswer = selectedOption;
    });

    if (_selectedAnswer == _questions[_currentQuestionIndex].correctAnswer) {
      _score += 10;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correct!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
        });
      } else {
        _showQuizResults();
      }
    });
  }

  // --- 5. UPDATED Method to Show Quiz Results ---
  void _showQuizResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quiz Completed!'),
        content: Text('You scored $_score points for the ${widget.topic} quiz!'),
        actions: [
          // --- NEW BUTTON ADDED HERE ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Move On', style: TextStyle(color: Colors.white)),
            onPressed: () {
              // Note: You can pass the score back to the home screen if you implement
              // a scoring system later, like so: Navigator.of(context).pop(_score);

              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Go back to the HomeScreen
            },
          ),
        ],
      ),
    );
  }

  // --- 6. Build Method (UI Layout) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic} Quiz'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text('Error: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchQuizQuestions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Text(
              _questions.isNotEmpty ? _questions[_currentQuestionIndex].question : "Loading question...",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_questions.isNotEmpty)
              ..._questions[_currentQuestionIndex].options.entries.map((entry) {
                String optionKey = entry.key;
                String optionValue = entry.value;
                // *** TYPO FIXED HERE ***
                bool isCorrect = optionKey == _questions[_currentQuestionIndex].correctAnswer;
                bool isSelected = optionKey == _selectedAnswer;

                Color? cardColor;
                if (_selectedAnswer != null) {
                  if (isCorrect) {
                    cardColor = Colors.green[100];
                  } else if (isSelected && !isCorrect) {
                    cardColor = Colors.red[100];
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: cardColor ?? Colors.white,
                  elevation: 2,
                  child: InkWell(
                    onTap: _selectedAnswer == null
                        ? () => _checkAnswer(optionKey)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text('$optionKey. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(optionValue)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

