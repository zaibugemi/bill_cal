import 'package:flutter/material.dart';
import 'categories_rate.dart';

class CategoriesState extends ChangeNotifier {

  CategoriesState(Map<String, Category> categories) {
    electricitySettings = ElectricitySettings(categories: categories);
  }

  var electricitySettings = ElectricitySettings(categories: {});

  void addCategory(category, categoryName) {
    electricitySettings.categories[categoryName] = category;
    notifyListeners();
  }

  void deleteCategory(categoryName) {
    electricitySettings.categories.remove(categoryName);
    notifyListeners();
  }

  void loadCategories(Map<String, Category> categories) {
    electricitySettings.categories = categories;
    notifyListeners();
  }

  bool keyExists(categoryName) {
    return electricitySettings.categories.containsKey(categoryName);
  }
}
