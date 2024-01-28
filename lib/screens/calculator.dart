import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../classes/categories_state.dart';
import '../classes/categories_rate.dart';

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
  final categoryController = TextEditingController();
  final _calculatorFormKey = GlobalKey<FormState>();
  bool calculateButtonHasBeenClickedAtLeastOnce = false;

  @override
  Widget build(BuildContext context) {
    var categoriesState = context.watch<CategoriesState>();
    var electricitySettings = categoriesState.electricitySettings;
    if (categoryController.text.isEmpty) {
      categoryController.text = electricitySettings.categories.keys.toList()[0];
    }

    double calculateBill() {
      int lastReading = int.tryParse(lastReadingController.text) ?? 0;
      int newReading = int.tryParse(newReadingController.text) ?? 0;
      String selectedCategory = categoryController.text;
      Category category = electricitySettings.categories[selectedCategory]!;
      int unitsConsumed = newReading - lastReading;

      if (category.hasFlatRate) {
        return unitsConsumed * category.rates.first.rate;
      } else {
        double totalBill = 0;
        for (var rate in category.rates) {
          if (unitsConsumed <= 0) {
            break;
          }
          int unitsToConsider =
              unitsConsumed <= rate.units ? unitsConsumed : rate.units;
          totalBill += unitsToConsider * rate.rate;
          unitsConsumed -= unitsToConsider;
        }

        if (unitsConsumed > 0) {
          totalBill += unitsConsumed * category.rates.last.rate;
        }
        return totalBill;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Center(
        child: Form(
          key: _calculatorFormKey,
          child: Column(
            children: [
              TextFormField(
                controller: lastReadingController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(labelText: 'Last Reading'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Invalid value';
                  }

                  int? parsedValue = int.tryParse(value);
                  if (parsedValue == null || parsedValue < 0) {
                    return 'Invalid value';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: newReadingController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(labelText: 'New Reading'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Invalid value';
                  }

                  int? parsedValue = int.tryParse(value);
                  if (parsedValue == null || parsedValue < 0) {
                    return 'Invalid value';
                  }

                  int? lastReadingParsed =
                      int.tryParse(lastReadingController.text)!;

                  if (parsedValue <= lastReadingParsed) {
                    return 'new reading must be greater than last reading';
                  }

                  return null;
                },
              ),
              DropdownButton<String>(
                value: categoryController.text,
                onChanged: (String? newValue) {
                  setState(() {
                    categoryController.text = newValue!;
                    if (calculateButtonHasBeenClickedAtLeastOnce) {
                      billAmount = calculateBill();
                    }
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_calculatorFormKey.currentState!.validate()) {
                    setState(() {
                      billAmount = calculateBill();
                      if (!calculateButtonHasBeenClickedAtLeastOnce) {
                        calculateButtonHasBeenClickedAtLeastOnce = true;
                      }
                    });
                  }
                },
                child: const Text('Calculate Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
