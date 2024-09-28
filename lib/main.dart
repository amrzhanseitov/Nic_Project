import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}


class Counter with ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Counter(),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => MyHomePage(),
          '/second': (context) => SecondScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String displayText = 'Hello World!';
  String userInput = '';
  String savedData = 'No data saved';
  String apiData = 'No data from API';
  

  void _updateText() {
    setState(() {
      displayText = 'Button Clicked!';
    });
  }


  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_data', userInput);
    setState(() {
      savedData = 'Saved: $userInput';
    });
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedData = prefs.getString('user_data') ?? 'No data found';
    });
  }


  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        apiData = data['title'];
      });
    } else {
      setState(() {
        apiData = 'Failed to load API data';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Counter>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Project for NIS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(displayText, style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: _updateText,
              child: Text('Click Me'),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) => setState(() => userInput = value),
              decoration: InputDecoration(labelText: 'Enter text'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveData,
              child: Text('Save Data'),
            ),
            Text(savedData),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/second'),
              child: Text('Go to Second Screen'),
            ),
            SizedBox(height: 20),
            Text('Count: ${counter.count}', style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: () => counter.increment(),
              child: Text('Increment Counter'),
            ),
            SizedBox(height: 20),
            Text('API Data: $apiData'),
          ],
        ),
      ),
    );
  }
}


class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is the second screen', style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
