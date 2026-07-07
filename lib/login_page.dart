import "package:flutter/material.dart";


class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(child: Image.asset('assets/screen.png' , width: 60, height: 60)),
            const SizedBox(height: 10),
            const Text(
              'Git Streak',
              style: TextStyle(color: Color.fromARGB(255, 88, 233, 93), fontSize: 40, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            const Text(
              'Track your coding streaks effortlessly!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            //Username TextField            
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.alternate_email, color: Colors.white),
                  hintText: 'Enter your GitHub username',
                  hintStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.black54,
                ),
              ),
            ),
            //Password TextField
            Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                  hintText: 'Enter your GitHub Password',
                  hintStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 375,
              child: ElevatedButton(
                onPressed: () {
              
                },
                 child: const Text('Connect ➜'),
                 style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 88, 233, 93),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}