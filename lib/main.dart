import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _itemNames = [];
  bool _isLoading = false;

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://api.restful-api.dev/objects'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _itemNames = data
              .map((item) => (item as Map<String, dynamic>)['name'] as String)
              .toList();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Request failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching items: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearItems() {
    setState(() {
      _itemNames = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: .start,
          children: [
            Row(
              mainAxisAlignment: .center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchItems,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Press Me'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _itemNames.isEmpty ? null : _clearItems,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _itemNames.isEmpty
                  ? const Text('No items loaded yet.')
                  : ListView.builder(
                      itemCount: _itemNames.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_itemNames[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
