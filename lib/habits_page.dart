import "package:flutter/material.dart";

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  bool isCompleted = false;
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> habits = [
    {
      "name": "Coding",
      "days": 124,
      "completed": true,
      "selected": false,
      "icon": Icons.computer,
    },
    {
      "name": "Read 20 min",
      "days": 14,
      "completed": false,
      "selected": false,
      "icon": Icons.menu_book,
    },
    {
      "name": "Workout",
      "days": 42,
      "completed": false,
      "selected": false,
      "icon": Icons.fitness_center,
    },
  ];

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
            icon: Icon(Icons.notifications_outlined),
          ),
          if (habits.any((habit) => habit["selected"] == true))
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteSelectedHabits,
            ),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 28, 34, 28),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color.fromARGB(255, 78, 101, 78),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Streak',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '129 ',
                                style: TextStyle(
                                  color: Colors.green[400],
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      //Completion Rate Card
                      SizedBox(
                        width: 165,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 28, 34, 28),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(255, 78, 101, 78),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Completion',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '67%',
                                  style: TextStyle(
                                    color: Colors.green[400],
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 165,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 28, 34, 28),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(255, 78, 101, 78),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'XP Earned',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '10K ',
                                  style: TextStyle(
                                    color: Colors.green[400],
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          habits[index]['selected'] =
                              !habits[index]['selected'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: habits[index]["selected"]
                              ? Colors.green.withOpacity(0.2)
                              : const Color(0xff1D2128),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          leading: Icon(
                            habits[index]["icon"],
                            color: Colors.green,
                          ),
                          title: Text(
                            habits[index]["name"],
                            style: const TextStyle(color: Colors.white),
                          ),

                          subtitle: Text(
                            "${habits[index]["days"]} days",
                            style: const TextStyle(color: Colors.grey),
                          ),

                          trailing: GestureDetector(
                            onTap: () {
                              setState(() {
                                habits[index]["completed"] =
                                    !habits[index]["completed"];
                              });
                            },
                            child: Icon(
                              Icons.check_circle,
                              color: habits[index]["completed"]
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void deleteSelectedHabits() {
    setState(() {
      habits.removeWhere((habit) => habit["selected"] == true);
    });
  }

  void addHabit() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Habit"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.clear();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  habits.add({
                    "name": controller.text,
                    "days": 0,
                    "completed": false,
                    "selected": false,
                    "icon": Icons.task_alt,
                  });
                });

                controller.clear();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
