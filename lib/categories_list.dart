import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'classes/categories_state.dart';
import 'package:bill_cal/database/bill_db.dart';
import 'add_category.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var categoriesState = context.watch<CategoriesState>();
    var electricityCategories = categoriesState.electricitySettings.categories;

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 9.0, bottom: 9.0),
          child: const Text(
            "Categories",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
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
                leading: IconButton(
                  onPressed: () async {
                    var db = DatabaseHelper();
                    db.deleteCategory(category.name);
                    categoriesState.deleteCategory(category.name);
                    db.getRates();
                  },
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Category',
                ),
                children: <Widget>[
                  DataTable(
                    columns: const [
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Units',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Rate',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ],
                    rows: category.rates.map((r) {
                      return DataRow(cells: <DataCell>[
                        DataCell(Text('${r.units}')),
                        DataCell(Text('${r.rate}'))
                      ]);
                    }).toList(),
                  ),
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
                    builder: (context) => const AddCategoryForm()));
          },
          child: const Text('Add Category'),
        ),
      ],
    );
  }
}
