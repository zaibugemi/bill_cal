import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
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
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                      icon: Icon(Icons.calculate), label: Text('Calculate')),
                  NavigationRailDestination(
                      icon: Icon(Icons.settings), label: Text('Settings'))
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              )),
              Expanded(
                  child: Container(
                margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ))
            ],
          ));
    });
  }
}

class CategoriesState extends ChangeNotifier {
  var electricitySettings = ElectricitySettings(categories: {
    'Domestic': Category(name: 'Domestic', isFlatRate: false, rates: <Rate>[
      Rate(startUnits: 0, endUnits: 50, rate: 7.0),
      Rate(startUnits: 51, endUnits: 150, rate: 9.0),
      Rate(startUnits: 151, endUnits: 300, rate: 11.0),
      Rate(startUnits: 301, endUnits: 99999, rate: 12.0)
    ]),
    'Commercial1': Category(
        name: 'com1',
        isFlatRate: true,
        rates: <Rate>[Rate(startUnits: 0, endUnits: 99999, rate: 7.0)]),
  });
}

class ElectricityBillCalculator extends StatefulWidget {
  const ElectricityBillCalculator({Key? key}) : super(key: key);

  @override
  State<ElectricityBillCalculator> createState() =>
      _ElectricityBillCalculatorState();
}

class _ElectricityBillCalculatorState extends State<ElectricityBillCalculator> {
  double billAmount = 0;

  final lastReadingController = TextEditingController();
  final newReadingController = TextEditingController();
  final categoryController = TextEditingController(text: 'Domestic');

  @override
  Widget build(BuildContext context) {
    var categoriesState = context.watch<CategoriesState>();
    var electricitySettings = categoriesState.electricitySettings;

    double calculateBill() {
      int lastReading = int.tryParse(lastReadingController.text) ?? 0;
      int newReading = int.tryParse(newReadingController.text) ?? 0;
      String selectedCategory = categoryController.text;
      Category category = electricitySettings.categories[selectedCategory]!;
      int unitsConsumed = newReading - lastReading;

      if (category.isFlatRate) {
        return unitsConsumed * category.rates.first.rate;
      } else {
        double totalBill = 0;
        for (var rate in category.rates) {
          if (unitsConsumed <= 0) {
            break;
          }
          int unitsInCurrentRange = rate.endUnits - rate.startUnits + 1;
          int unitsToConsider = unitsConsumed <= unitsInCurrentRange
              ? unitsConsumed
              : unitsInCurrentRange;
          totalBill += unitsToConsider * rate.rate;
          unitsConsumed -= unitsToConsider;
        }
        return totalBill;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Center(
        child: Column(children: [
          TextField(
            controller: lastReadingController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(labelText: 'Last Reading'),
          ),
          TextField(
            controller: newReadingController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(labelText: 'New Reading'),
          ),
          DropdownButton<String>(
            value: categoryController.text,
            onChanged: (String? newValue) {
              setState(() {
                categoryController.text = newValue!;
                billAmount = calculateBill();
              });
            },
            items: electricitySettings.categories.keys
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            dropdownColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Bill Amount: Rs. ${billAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  billAmount = calculateBill();
                });
              },
              child: const Text('Calculate Bill'))
        ]),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var categoriesState = context.watch<CategoriesState>();
    var electricityCategories = categoriesState.electricitySettings.categories;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: electricityCategories
                .length, // Replace with your actual item count
            itemBuilder: (BuildContext context, int index) {
              // Build your list items here
              var category = electricityCategories[
                  electricityCategories.keys.elementAt(index)];
              return ExpansionTile(
                title: Text(category!.name),
                children: <Widget>[
                  DataTable(
                    columns: const [
                      DataColumn(
                          label: Expanded(
                        child: Text(
                          'Units',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )),
                      DataColumn(
                          label: Expanded(
                        child: Text(
                          'Rate',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ))
                    ],
                    rows: category.rates.map((r) {
                      return DataRow(cells: <DataCell>[
                        DataCell(Text('${r.startUnits} - ${r.endUnits}')),
                        DataCell(Text('${r.rate}'))
                      ]);
                    }).toList(),
                  )
                ],
              );
            },
          ),
        ),
        Container(
          height: 10,
          color: Colors.white,
        ),
        ElevatedButton(
            onPressed: () {
              // Handle button press
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoryScreen()));
            },
            child: const Text('Add Category'))
      ],
    );
  }
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Category'),
        ),
        body: const Padding(
            padding: EdgeInsets.all(16), child: Text('Add Category')));
  }
}

class Rate {
  int startUnits;
  int endUnits;
  double rate;

  Rate({required this.startUnits, required this.endUnits, required this.rate});
}

class Category {
  String name;
  bool isFlatRate;
  List<Rate> rates;

  Category({required this.name, required this.isFlatRate, required this.rates});
}

class ElectricitySettings {
  Map<String, Category> categories;

  ElectricitySettings({required this.categories});
}
