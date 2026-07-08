import "package:flutter/material.dart";

class LoginPage extends StatefulWidget {
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
            Center(
              child: Image.asset('assets/screen.png', width: 60, height: 60),
            ),
            const SizedBox(height: 10),
            const Text(
              'Git Streak',
              style: TextStyle(
                color: Color.fromARGB(255, 88, 233, 93),
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 0),
            const Text(
              'Track your coding streaks effortlessly!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            //Username TextField
            Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                  hintText: 'Enter your GitHub Username',
                  hintStyle: const TextStyle(color: Colors.white),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                  ),

                  filled: true,
                  fillColor: Colors.black54,
                ),
              ),
            ),

            //Password TextField
            Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 18, 18.0, 0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                  hintText: 'Enter your GitHub Password',
                  hintStyle: const TextStyle(color: Colors.white),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                  ),

                  filled: true,
                  fillColor: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SizedBox(
                width: 375,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Connect ➜'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 88, 233, 93),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: const Text(
                'HELPFUL LINKS',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.help_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
                  label: const Text(
                    'How it Works?',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 78, 101, 78),
                        width: 0.7,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 27.5),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  label: const Text(
                    'Privacy Policy',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 78, 101, 78),
                        width: 0.7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Container(
            //     padding: const EdgeInsets.all(16),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10),
            //       border: Border.all(
            //         color: const Color.fromARGB(255, 78, 101, 78),
            //         width: 0.7,
            //       ),
            //       // color: const Color.fromARGB(156, 57, 55, 55),
            //     ),
            //     child: Text(
            //       'Your last 365 days of activity will be analyzed to build your unique developer momentum profile.',
            //       style: TextStyle(color: Colors.grey, fontSize: 16),
            //     ),
            //   ),
            // ),
            Text('Version 1.0.0', style: TextStyle(color: const Color.fromARGB(116, 158, 158, 158), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
