import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item_blueprint.dart';
import 'package:shopping_list/sreens/new_item.dart';

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
  final List<GroceryItem> _enteredItemsList = [];

  void addIconPusher() async {
    final newAddedItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewItem(),
      ),
    );
    if (newAddedItem == null) {
      return;
    }
    if (newAddedItem != null) {
      setState(() {
        _enteredItemsList.add(newAddedItem);
      });
    }
  }

  void _dismissingItems(GroceryItem item) {
    final itemIndex = _enteredItemsList.indexOf(item);
    setState(
      () {
        _enteredItemsList.remove(
          _enteredItemsList[itemIndex],
        );
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item Has Been Removed'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Restore',
              onPressed: () {
                setState(() {
                  _enteredItemsList.insert(
                    itemIndex,
                    item,
                  );
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = ListView.builder(
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
    if (_enteredItemsList.isEmpty) {
      setState(() {
        mainContent = Center(
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
