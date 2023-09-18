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
