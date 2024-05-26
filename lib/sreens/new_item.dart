// import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/items.dart';
import 'package:shopping_list/models/category_blueprint.dart';
// import 'package:shopping_list/models/grocery_item_blueprint.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item_blueprint.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _currentlyLoading = false;

  var _enteredItemName = '';
  var _enteredItemAmount = 1;
  var _initialCategory = categories[Categories.vegetables]!;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _currentlyLoading = true;
      });
      final url = Uri.https('Base URL', 'Path');
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
        body: json.encode(
          {
            'name': _enteredItemName,
            'quantity': _enteredItemAmount,
            'category': _initialCategory.itemName,
          },
        ),
      );
      final Map<String, dynamic> resData = json.decode(response.body);
      print(response.body);
      print(response.statusCode);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItem(
            id: resData['name'],
            name: _enteredItemName,
            quantity: _enteredItemAmount,
            category: _initialCategory),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: const InputDecoration(
                  label: Text('Item Name'),
                ),
                onSaved: (newValue) {
                  // if (newValue == null) {
                  //   return;
                  // }
                  _enteredItemName = newValue!;
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length >= 50) {
                    return 'The length must be between 1 and 50.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _enteredItemAmount.toString(),
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (newValue) {
                        _enteredItemAmount = int.parse(newValue!);
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value) == null ||
                            double.tryParse(value)! <= 0) {
                          return 'Enter a valid positive number.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _initialCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 20,
                                  width: 20,
                                  color: category.value.itemColor,
                                ),
                                const SizedBox(width: 10),
                                Text(category.value.itemName)
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _initialCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _currentlyLoading
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _currentlyLoading ? null : _saveItem,
                    child: _currentlyLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
