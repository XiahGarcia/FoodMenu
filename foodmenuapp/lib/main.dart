// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/menu_screen.dart';

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
