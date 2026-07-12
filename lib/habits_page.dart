import "package:flutter/material.dart";
class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Git Streak',
          style: TextStyle(
            color: Color.fromARGB(255, 88, 233, 93),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon:Icon(Icons.notifications_outlined),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Habits,',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Stay disciplined. Stay ahead.',
                style: TextStyle(color: Colors.grey, fontSize: 20),
              ),
              const SizedBox(height: 20),
              Row(children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 88, 233, 93),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Add Habit',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ],)
            ],
          ),
        ),
      ),
    );
  }
}