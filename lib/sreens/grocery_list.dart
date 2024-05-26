import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item_blueprint.dart';
import 'package:shopping_list/sreens/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({
    super.key,
    required this.groceryItemsList,
  });

  final List<GroceryItem> groceryItemsList;

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _enteredItemsList = [];

  var _isLoading = true;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('Base URL', 'Path');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Faild to fetch the data, please try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> dataList = json.decode(response.body);

      final List<GroceryItem> loadedItems = [];
      print(response.body);
      print('momomomomoo');

      // print(response.body);
      for (final item in dataList.entries) {
        final itemCategory = categories.entries
            .firstWhere(
                (catItem) => catItem.value.itemName == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key, //the key here is the special key assigned by firebase
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: itemCategory,
          ),
        );
      }
      setState(() {
        _enteredItemsList = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  void addIconPusher() async {
    final newAddedItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );
    // _loadItems();
    if (newAddedItem == null) {
      return;
    }
    if (newAddedItem != null) {
      setState(() {
        _enteredItemsList.add(newAddedItem);
      });
    }
  }

  void _dismissingItems(GroceryItem item) async {
    final itemIndex = _enteredItemsList.indexOf(item);

    setState(
      () {
        _enteredItemsList.remove(item);
        // _enteredItemsList[itemIndex], this was used when inserting
        // with the case of restoring using snackBar
      },
    );
    final url = Uri.https('Base URL', 'Path/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(
        () {
          _enteredItemsList.insert(itemIndex, item);
        },
      );
    }

    // ScaffoldMessenger.of(context).removeCurrentSnackBar();
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: const Text('Item Has Been Removed'),
    //     duration: const Duration(seconds: 3),
    //     action: SnackBarAction(
    //       label: 'Restore',
    //       onPressed: () {
    //         setState(() {
    //           _enteredItemsList.insert(
    //             itemIndex,
    //             item,
    //           );
    //         });
    //       },
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Add Some New Items',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: ThemeData().colorScheme.background,
                ),
          ),
        ],
      ),
    );
    if (_isLoading) {
      mainContent = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      mainContent = Center(
        child: Text(_error!),
      );
    }

    if (_enteredItemsList.isNotEmpty) {
      setState(() {
        mainContent = ListView.builder(
            itemCount: _enteredItemsList.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: ValueKey(_enteredItemsList[index]),
                background: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context)
                        .colorScheme
                        .copyWith()
                        .error
                        .withOpacity(0.5),
                  ),
                  margin: const EdgeInsets.all(10),
                ),
                onDismissed: (direction) =>
                    _dismissingItems(_enteredItemsList[index]),
                child: ListTile(
                  title: Text(
                    _enteredItemsList[index].name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: ThemeData().colorScheme.background,
                        ),
                  ),
                  leading: Container(
                    height: 20,
                    width: 20,
                    color: _enteredItemsList[index].category.itemColor,
                  ),
                  // const SizedBox(width: 20),

                  trailing: Text(
                    '${_enteredItemsList[index].quantity}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: ThemeData().colorScheme.background,
                        ),
                  ),
                ),
              );
            });
      });
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(
              onPressed: addIconPusher,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: mainContent);
  }
}
