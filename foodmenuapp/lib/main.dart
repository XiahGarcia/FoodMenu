import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://cewaojcvsodvxyqxsuyf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNld2FvamN2c29kdnh5cXhzdXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1NjE0MzEsImV4cCI6MjA0OTEzNzQzMX0.1dwO-GY0eI2hBXX2-eKfsx69VB79J6IGcEANwSPHxM0',
  );
  runApp(FoodMenuApp());
}

class FoodMenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> menuItems = [];

  @override
  void initState() {
    super.initState();
    fetchMenuItems();
  }

  // Fetch the list of menu items from Supabase
  Future<void> fetchMenuItems() async {
    final response = await supabase.from('list').select();
    setState(() {
      menuItems = response;
    });
  }

  // Add a new menu item to the Supabase table
  // Add a new menu item to the Supabase table
  Future<void> addMenuItem(
      String name, String priceStr, String category, bool availability) async {
    try {
      double price = 0.0;

      // Parse the price as a double only when it's a valid number
      if (priceStr.isNotEmpty && double.tryParse(priceStr) != null) {
        price = double.parse(priceStr); // Convert price to double
      } else {
        print("Invalid price: $priceStr");
        return; // Optionally show an error message to the user
      }

      // Insert the item into the Supabase table
      await supabase.from('list').insert({
        'name': name,
        'price': price, // Store as double
        'category': category,
        'availability': availability,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Refresh the menu items after adding the new item
      fetchMenuItems();
      print("Item added successfully");
    } catch (e) {
      print('Error adding item: $e');
    }
  }

// Edit an existing menu item
  Future<void> editMenuItem(int id, String name, String priceStr,
      String category, bool availability) async {
    try {
      double price = 0.0;

      // Parse the price as a double only when it's a valid number
      if (priceStr.isNotEmpty && double.tryParse(priceStr) != null) {
        price = double.parse(priceStr); // Convert price to double
      } else {
        print("Invalid price: $priceStr");
        return;
      }

      // Update the item in the Supabase table
      await supabase.from('list').update({
        'name': name,
        'price': price, // Store as double
        'category': category,
        'availability': availability,
      }).eq('id', id);

      fetchMenuItems();
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  // Delete a menu item
  Future<void> deleteMenuItem(int id) async {
    await supabase.from('list').delete().eq('id', id);
    fetchMenuItems(); // Refresh the list after deletion
  }

  // Show a dialog to add or edit a menu item
  void showAddEditDialog({dynamic item}) {
    final nameController = TextEditingController(text: item?['name'] ?? '');
    final priceController = TextEditingController(
        text: item?['price']?.toString() ?? ''); // Ensure it's a String
    final categoryController =
        TextEditingController(text: item?['category'] ?? '');

    // Set the initial value of availability to the current item value
    bool availability = item?['availability'] ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Add StatefulBuilder to preserve state
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item == null ? 'Add Menu Item' : 'Edit Menu Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  SwitchListTile(
                    title: const Text('Availability'),
                    value: availability,
                    onChanged: (value) {
                      setState(() {
                        availability = value; // Update the state on toggle
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Save the item to the database
                    if (item == null) {
                      addMenuItem(
                        nameController.text,
                        priceController.text, // Pass price as a String
                        categoryController.text,
                        availability, // Pass updated availability state
                      );
                    } else {
                      editMenuItem(
                        item['id'],
                        nameController.text,
                        priceController.text, // Pass price as a String
                        categoryController.text,
                        availability, // Pass updated availability state
                      );
                    }
                    Navigator.pop(context); // Close the dialog after saving
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
            icon: const Icon(Icons.refresh),
            onPressed: fetchMenuItems,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(item['name']),
              subtitle: Text(
                  'Price: \$${item['price']} | ${item['availability'] ? "Available" : "Unavailable"}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showAddEditDialog(item: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteMenuItem(item['id']),
                  ),
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
