import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // For API keys

// Placeholder for your actual Task model
class QuizQuestion {
  final String question;
  final Map<String, String> options;
  final String correctAnswer;

  QuizQuestion({required this.question, required this.options, required this.correctAnswer});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: Map<String, String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
    );
  }
}

class tasks extends StatefulWidget {
  final String topic;

  const tasks({Key? key, required this.topic}) : super(key: key);

  @override
  State<tasks> createState() => _tasksState();
}

class _tasksState extends State<tasks> {
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  String? _error;
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuizQuestions();
  }

  Future<void> _fetchQuizQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with your actual API endpoint and key
      // final apiKey = dotenv.env['GEMINI_API_KEY'];
      // final url = Uri.parse('YOUR_GEMINI_API_ENDPOINT');
      // final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'};

      // Using a dummy API call for demonstration.
      // You would replace this with your actual LLM API integration.
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

      final String dummyJsonResponse = '''
      [
        {
          "question": "Which of these is NOT a common recyclable material?",
          "options": {"A": "Glass bottles", "B": "Plastic bags", "C": "Aluminum cans", "D": "Cardboard"},
          "correctAnswer": "B"
        },
        {
          "question": "What is the primary benefit of reducing water usage in households?",
          "options": {"A": "Increases property value", "B": "Lowers utility bills and conserves resources", "C": "Makes plants grow faster", "D": "Attracts more wildlife"},
          "correctAnswer": "B"
        },
        {
          "question": "Biodiversity refers to the variety of life on Earth at all its levels. Which of these is a key reason to protect it?",
          "options": {"A": "It provides all human food sources", "B": "It helps ecosystems function and provides essential services", "C": "It prevents natural disasters", "D": "It guarantees new medical cures"},
          "correctAnswer": "B"
        }
      ]
      ''';

      final List<dynamic> jsonList = json.decode(dummyJsonResponse);
      _questions = jsonList.map((json) => QuizQuestion.fromJson(json)).toList();

    } catch (e) {
      _error = 'Failed to load quiz: $e';
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
      _score += 10; // Award points for correct answer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correct!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }

    // Move to next question after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null; // Reset for next question
        });
      } else {
        _showQuizResults();
      }
    });
  }

  void _showQuizResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Text('You scored $_score points for the ${widget.topic} quiz!'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Send _score to a backend/local storage
              Navigator.of(context).pop(); // Close results dialog
              Navigator.of(context).pop(); // Go back to Home Screen
            },
            child: const Text('Great!'),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic} Quiz'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
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
              _questions[_currentQuestionIndex].question,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ..._questions[_currentQuestionIndex].options.entries.map((entry) {
              String optionKey = entry.key;
              String optionValue = entry.value;
              bool isCorrect = optionKey == _questions[_currentQuestionIndex].correctAnswer;
              bool isSelected = optionKey == _selectedAnswer;

              Color? cardColor;
              if (_selectedAnswer != null) {
                if (isCorrect) {
                  cardColor = Colors.green[100]; // Highlight correct answer
                } else if (isSelected && !isCorrect) {
                  cardColor = Colors.red[100]; // Highlight incorrect selected answer
                }
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: cardColor ?? Colors.white,
                elevation: 2,
                child: InkWell(
                  onTap: _selectedAnswer == null ? () => _checkAnswer(optionKey) : null, // Disable tapping after selection
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