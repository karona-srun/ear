import 'package:earai/sound_screen.dart';
import 'package:flutter/material.dart';

class StarterScreen extends StatefulWidget {
  const StarterScreen({super.key});

  @override
  State<StarterScreen> createState() => _StarterScreenState();
}

class _StarterScreenState extends State<StarterScreen> {
  String text = '';
  final _controller = TextEditingController();
  bool _validate = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.all(30),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50),
              Text(
                'Hi, I am EarAI,',
                style: TextStyle(
                  fontSize: 34, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8), // Added space
              Text(
                'your deaf assistant.',
                style: TextStyle(
                  fontSize: 34, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18), // More space before the text field
              Text(
                'To help you better, I would like to know your name.',
                style: TextStyle(
                  fontSize: 12, // Adjusted for subtext
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10), // Space before input field
              Text(
                'How would you like me to call you?',
                style: TextStyle(
                  fontSize: 18, // Adjusted for subtext
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _controller,
                onChanged: (value) => setState(() => text = value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: 'Please Enter',
                  errorText: _validate ? "Value Can't Be Empty" : null,
                  hintStyle: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 16), // Space before the button
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _validate = _controller.text.isEmpty;
                      });
                      if(_controller.text.isNotEmpty){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SoundScreen(
                                  title: "EarAI", name: text.toString())),
                        );
                      }
                    },
                    child: Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.grey, // Correct property for background color
                      minimumSize: Size(double.infinity, 50), // Button size
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Button border radius
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
