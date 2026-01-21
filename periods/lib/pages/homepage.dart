import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onLogout;

  const HomePage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Periods Tracker'),
        backgroundColor: const Color(0xFFE91E63), // Pink
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8BBD9), // Pastel pink
              Color(0xFFE1BEE7), // Pastel purple
              Color(0xFFB3E5FC), // Pastel blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF424242),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your cycle with ease',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF757575),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: PageView.builder(
                    itemCount: 28, // Assuming a 28-day cycle
                    itemBuilder: (context, index) {
                      int day = index + 1;
                      return Center(
                        child: Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFCDD2), // Light pink
                                  Color(0xFFF8BBD9), // Pastel pink
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  size: 48.0,
                                  color: Color(0xFFE91E63),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'Day $day',
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: const Color(0xFF424242),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'of your menstrual cycle',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF757575),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'Track your symptoms and mood today',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF9E9E9E),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
      ),
    );
  }
}