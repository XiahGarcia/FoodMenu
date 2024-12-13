import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item.dart';

class MenuController {
  final SupabaseClient supabase;

  MenuController({required this.supabase});

  // Fetch menu items from the Supabase database
  Future<List<MenuItem>> fetchMenuItems() async {
    final List<dynamic> result = await supabase.from('list').select();
    return result
        .map((item) => MenuItem.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  // Add a new menu item to Supabase
  Future<void> addMenuItem(MenuItem item) async {
    final data = item.toMap();
    data.remove('id'); // Prevent inserting a duplicate ID
    await supabase.from('list').insert(data);
  }

  // Edit an existing menu item
  Future<void> editMenuItem(MenuItem item) async {
    await supabase.from('list').update(item.toMap()).eq('id', item.id);
  }

  // Delete a menu item
  Future<void> deleteMenuItem(int id) async {
    await supabase.from('list').delete().eq('id', id);
  }
}
