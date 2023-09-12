import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: "Namer App",
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent)),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>{}; // this is a set definition

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void remove(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = LikedList();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constrains) {
      print(constrains);
      return Scaffold(
          body: Row(
        children: [
          SafeArea(
              child: NavigationRail(
            // Aqui extended controla sin se muestran los label o no, un
            // valor de true hace que se muestren por lo que aquí se
            // se controla el extendido basandose en el ancho maximo de pixeles.
            extended: constrains.maxWidth >= 600,
            selectedIndex: selectedIndex,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text('Home')),
              NavigationRailDestination(
                  icon: Icon(Icons.favorite), label: Text('Favorites'))
            ],
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          )),
          Expanded(
              child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: page,
          ))
        ],
      ));
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('A random idea:'),
            SizedBox(height: 17),
            BigCard(pair: pair),
            SizedBox(height: 17),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleFavorite();
                    },
                    icon: Icon(icon),
                    label: Text('Like')),
                SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () {
                      appState.getNext();
                    },
                    child: Text('Next')),
              ],
            )
          ]),
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asCamelCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class LikedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var f in favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(f.asCamelCase),
            onTap: () {
              appState.remove(f);
            },
          )
      ],
    );
  }
}
