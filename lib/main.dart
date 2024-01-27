import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bill_cal/database/bill_db.dart';
import 'classes/categories_state.dart';
import 'add_category.dart';
import 'calculator.dart';
import 'categories_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CategoriesState(),
      child: MaterialApp(
        title: 'Electricity Bill Calculator',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // late DatabaseHelper db;
  int selectedIndex = 0;
  bool _isInitialized = false;

  loadCategories(context) async {
    var db = DatabaseHelper();
    var categoriesFromDB = await db.getCategories();
    var categoriesState = Provider.of<CategoriesState>(context, listen: false);
    categoriesState.loadCategories(categoriesFromDB);
  }

  @override
  void didChangeDependencies() {
    if (!_isInitialized) {
      loadCategories(context);
      _isInitialized = true;
    }
    super.didChangeDependencies();
  }

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
