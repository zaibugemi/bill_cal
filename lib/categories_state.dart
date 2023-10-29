import 'package:flutter/material.dart';
import 'classes/categories_rate.dart';

class CategoriesState extends ChangeNotifier {
  var electricitySettings = ElectricitySettings(categories: {
    'Domestic': Category(name: 'Domestic', hasFlatRate: false, rates: <Rate>[
      Rate(units: 50, rate: 7.0),
      Rate(units: 100, rate: 9.0),
      Rate(units: 150, rate: 11.0),
      Rate(units: 99999, rate: 12.0)
    ]),
    'Commercial1': Category(
        name: 'com1',
        hasFlatRate: true,
        rates: <Rate>[Rate(units: 99999, rate: 7.0)]),
  });

  void addCategory(category, categoryName) {
    electricitySettings.categories[categoryName] = category;
    notifyListeners();
  }

  bool keyExists(categoryName) {
    return electricitySettings.categories.containsKey(categoryName);
  }
}
