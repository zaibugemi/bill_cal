import 'package:flutter/material.dart';
import 'classes/categories_rate.dart';

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

  void addCategory(category, categoryName) {
    electricitySettings.categories[categoryName] = category;
    notifyListeners();
  }

  bool keyExists(categoryName) {
    return electricitySettings.categories.containsKey(categoryName);
  }
}
