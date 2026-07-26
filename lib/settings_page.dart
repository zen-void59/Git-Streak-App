import "dart:math";

import "package:flutter/material.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 88, 233, 93),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 0, height: 12),
              SizedBox(
                width: 400,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(255, 78, 101, 78),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 88, 233, 93),
                          size: 30,
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Ayush_Thakur',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 0, top: 0),
                            child: Text(
                              'Github Connected',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 89, 79, 79),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 120.0),
                        child: CircleAvatar(
                          //forward Arrow
                          radius: 25,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Color.fromARGB(255, 88, 233, 93),
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height:20),
              SizedBox(
                width:400,
                height:90,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:Border.all(
                      color:Color.fromARGB(255, 78, 101, 78),
                      width:1.5,
                    )
                  ),
                ),
              ),

              const SizedBox(height:10),

              SizedBox(
                width:400,
                height:90,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:Border.all(
                      color:Color.fromARGB(255, 78, 101, 78),
                      width:1.5,
                    )
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
