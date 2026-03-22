import 'package:flutter/material.dart';
import 'package:vora/backend/services/quotes_services.dart';

class QuotesPage extends StatelessWidget {
  const QuotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Motivation Quotes")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: QuotesService.instance.getRandomQuote(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return Center(child: Text("Error: ${snap.error}"));
            }

            final q = snap.data;
            if (q == null) {
              return const Center(child: Text("No quotes found"));
            }

            final text = (q['text'] ?? '').toString();
            final author = (q['author'] ?? 'Unknown').toString();
            final category = (q['category'] ?? 'Motivation').toString();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$text"',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "— $author",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "Category: $category",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    // refresh page by pushing replacement
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const QuotesPage()),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Show another quote"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
