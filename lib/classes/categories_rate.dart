class Rate {
  int startUnits;
  int endUnits;
  double rate;

  Rate({required this.startUnits, required this.endUnits, required this.rate});
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
