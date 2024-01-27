import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'classes/categories_state.dart';
import 'classes/categories_rate.dart';

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
        child: Column(
          children: [
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
              child: const Text('Calculate Bill'),
            ),
          ],
        ),
      ),
    );
  }
}
