// lib/views/menu_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/menu_controller.dart'
    as menu_ctrl; // Alias the MenuController import
import '../models/menu_item.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late final menu_ctrl.MenuController menuController; // Use the alias here
  List<MenuItem> menuItems = [];

  @override
  void initState() {
    super.initState();
    menuController = menu_ctrl.MenuController(
        supabase: Supabase.instance.client); // Use the alias here
    fetchMenuItems();
  }

  // Fetch the list of menu items
  Future<void> fetchMenuItems() async {
    final items = await menuController.fetchMenuItems();
    setState(() {
      menuItems = items;
    });
  }

  // Show the add/edit dialog for menu items
  void showAddEditDialog({MenuItem? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController =
        TextEditingController(text: item?.price.toString() ?? '');
    final categoryController =
        TextEditingController(text: item?.category ?? '');
    bool availability = item?.availability ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item == null ? 'Add Menu Item' : 'Edit Menu Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name')),
                  TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number),
                  TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category')),
                  SwitchListTile(
                    title: const Text('Availability'),
                    value: availability,
                    onChanged: (value) {
                      setState(() {
                        availability = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (item == null) {
                      menuController.addMenuItem(MenuItem(
                        id: 0,
                        name: nameController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        category: categoryController.text,
                        availability: availability,
                      ));
                    } else {
                      menuController.editMenuItem(MenuItem(
                        id: item.id,
                        name: nameController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        category: categoryController.text,
                        availability: availability,
                      ));
                    }
                    Navigator.pop(context);
                    fetchMenuItems();
                  },
                  child: Text(item == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Menu'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: fetchMenuItems),
        ],
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(
                  'Price: \$${item.price} | ${item.availability ? "Available" : "Unavailable"}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showAddEditDialog(item: item)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => menuController.deleteMenuItem(item.id)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
