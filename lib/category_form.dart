import 'package:bill_cal/database/bill_db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'categories_state.dart';
import 'classes/categories_rate.dart';

const maxUnitsForFlatRate = 99999;

class AddCategoryForm extends StatefulWidget {
  const AddCategoryForm({super.key});

  @override
  AddCategoryFormState createState() {
    return AddCategoryFormState();
  }
}

class AddCategoryFormState extends State<AddCategoryForm> {
  final _categoryNameKey = GlobalKey<FormFieldState>();
  final _rateFormKey = GlobalKey<FormState>();
  bool _hasFlatRate = false;
  var rateDivisions = <Rate>[];

  final startUnitController = TextEditingController();
  final endUnitController = TextEditingController();
  final rateController = TextEditingController();

  late FocusNode startUnitFocusNode;

  @override
  void initState() {
    super.initState();

    startUnitFocusNode = FocusNode();
  }

  @override
  void dispose() {
    startUnitFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var categoriesState = context.watch<CategoriesState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Category')),
      body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              TextFormField(
                key: _categoryNameKey,
                autofocus: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Category Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid name';
                  }
                  return null;
                },
              ),
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: SwitchListTile(
                    contentPadding: const EdgeInsets.only(left: 8.0, right: 0),
                    title: const Text('Flat rate'),
                    value: _hasFlatRate,
                    onChanged: (bool value) {
                      setState(() {
                        _hasFlatRate = value;

                        if (value == true) {
                          // set the units range for flat rate
                          startUnitController.text = '1';
                          endUnitController.text = '$maxUnitsForFlatRate';
                          if (rateDivisions.length > 1) {
                            rateDivisions[0].startUnits = 1;
                            rateDivisions[0].endUnits = maxUnitsForFlatRate;
                            rateDivisions = [rateDivisions[0]];
                          }
                        } else {
                          // reset the unit range
                          startUnitController.text = '';
                          endUnitController.text = '';
                        }
                      });
                    }),
              ),
              (!_hasFlatRate || (_hasFlatRate && rateDivisions.isEmpty))
                  ? Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, bottom: 10.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0))),
                      child: Form(
                        key: _rateFormKey,
                        child: Column(
                          children: [
                            Row(children: [
                              if (!_hasFlatRate)
                                Expanded(
                                  child: TextFormField(
                                    focusNode: startUnitFocusNode,
                                    controller: startUnitController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        labelText: 'units start'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Invalid number';
                                      }

                                      int? parsedValue = int.tryParse(value);
                                      if (parsedValue == null) {
                                        return 'Invalid number';
                                      }

                                      if (parsedValue < 0) {
                                        return 'Invalid number';
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                              if (!_hasFlatRate)
                                const SizedBox(
                                  width: 20.0,
                                ),
                              if (!_hasFlatRate)
                                Expanded(
                                  child: TextFormField(
                                    controller: endUnitController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        labelText: 'units end'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Invalid number';
                                      }
                                      int? parsedValue = int.tryParse(value);
                                      if (parsedValue == null) {
                                        return 'Invalid number';
                                      }

                                      if (parsedValue < 0) {
                                        return 'Invalid number';
                                      }

                                      int? startUnitParsed = int.tryParse(
                                          startUnitController.text);

                                      if (startUnitParsed != null) {
                                        if (startUnitParsed >= parsedValue) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            duration: Duration(seconds: 6),
                                            content: Text(
                                                "'units end' should be greater than 'units start'"),
                                          ));
                                          return 'Invalid number';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              if (!_hasFlatRate)
                                const SizedBox(
                                  width: 20.0,
                                ),
                              Expanded(
                                  child: TextFormField(
                                controller: rateController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'rate'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Invalid number';
                                  }

                                  double? parsedValue = double.tryParse(value);
                                  if (parsedValue == null) {
                                    return 'Invalid number';
                                  }

                                  if (parsedValue < 0) {
                                    return 'Invalid number';
                                  }

                                  return null;
                                },
                              ))
                            ]),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (_rateFormKey.currentState!
                                          .validate()) {
                                        setState(() {
                                          rateDivisions.add(Rate(
                                              startUnits: int.parse(
                                                  startUnitController.text),
                                              endUnits: int.parse(
                                                  endUnitController.text),
                                              rate: double.parse(
                                                  rateController.text)));

                                          startUnitController.text = '';
                                          endUnitController.text = '';
                                          rateController.text = '';
                                        });

                                        startUnitFocusNode.requestFocus();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                    ),
                                    label: const Text('Add Rate'),
                                  )),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),
              Expanded(
                  child: rateDivisions.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
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
                            rows: rateDivisions.map((r) {
                              return DataRow(cells: <DataCell>[
                                DataCell(
                                    Text('${r.startUnits} - ${r.endUnits}')),
                                DataCell(Text('${r.rate}'))
                              ]);
                            }).toList(),
                          ),
                        )
                      : Container()),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    var categoryNameInput =
                        _categoryNameKey.currentState!.value;
                    if (_categoryNameKey.currentState!.validate()) {
                      if (rateDivisions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please add a rate!')));
                      } else if (categoriesState.keyExists(categoryNameInput)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Category name already exists!')));
                      } else {
                        final categoryToAdd = Category(
                            name: categoryNameInput,
                            hasFlatRate: _hasFlatRate,
                            rates: rateDivisions);

                        var db = DatabaseHelper();
                        await db.addCategory(categoryToAdd);
                        // var categories = await db.getCategories();

                        categoriesState.addCategory(
                            categoryToAdd, categoryNameInput);

                        // check that the widget that provided context is still in the widget tree after the async operation
                        if (context.mounted) {
                          if (categoriesState
                                      .electricitySettings.categories.length -
                                  1 >
                              0) {
                            Navigator.pop(context);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Category Added!')));
                        }
                      }
                    }
                  },
                  child: const Text('Add Category'),
                ),
              )
            ],
          )),
    );
  }
}
