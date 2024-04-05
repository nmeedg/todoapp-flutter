import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Notes'),
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
  late TextEditingController _textController;

  void submitText() {
    debugPrint(_textController.text);
  }

@override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  suffixIcon: Icon(Icons.search),
                  hintText: "Enter the title or words of notes",
                  contentPadding: EdgeInsets.all(15)),
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 20,),
            Expanded(
                child: ListView.separated(
                    itemBuilder: (ctx, index) => ListTile(
                          title: Text("Item $index"),
                          trailing: Icon(Icons.more_vert_rounded),
                        ),
                    separatorBuilder: (ctx, index) => Divider(),
                    itemCount: 15))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitText,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
