import 'package:bill_cal/classes/categories_rate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bill_cal/database/bill_db.dart';
import 'classes/categories_state.dart';
import 'screens/add_category.dart';
import 'screens/calculator.dart';
import 'screens/categories_list.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const BillCalculatorApp());

class BillCalculatorApp extends StatelessWidget {
  const BillCalculatorApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const AppWithDB();
  }
}

class AppWithDB extends StatefulWidget {
  const AppWithDB({super.key});

  @override
  State<AppWithDB> createState() => _AppWithDBState();
}

Future<Map<String, Category>> fetchCategoriesFromDB() async {
  var db = DatabaseHelper();
  return db.getCategories();
}

class _AppWithDBState extends State<AppWithDB> {
  final Future<Map<String, Category>> _categoriesFromDB =
      fetchCategoriesFromDB();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _categoriesFromDB,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return ChangeNotifierProvider(
              create: (context) => CategoriesState(snapshot.data!),
              child: MaterialApp(
                title: 'Electricity Bill Calculator',
                theme: ThemeData(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  useMaterial3: true,
                ),
                home: const MyHomePage(),
              ),
            );
          } else {
            return const MaterialApp(
              title: 'Electricity Bill Calculator',
              home: SplashScreen(),
            );
          }
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var categoriesState = context.watch<CategoriesState>();

    if (categoriesState.electricitySettings.categories.isEmpty) {
      return const AddCategoryForm();
    }

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const ElectricityBillCalculator();
        break;
      case 1:
        page = const SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(title: const Text('Electricity Bill Calculator')),
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.calculate),
                    label: Text('Calculate'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}
