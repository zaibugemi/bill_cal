class Rate {
  int units;
  double rate;

  Rate({required this.units, required this.rate});
}

class Category {
  String name;
  bool hasFlatRate;
  List<Rate> rates;

  Category(
      {required this.name, required this.hasFlatRate, required this.rates});
}

class ElectricitySettings {
  Map<String, Category> categories;

  ElectricitySettings({required this.categories});
}
