import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnitsScreen extends StatelessWidget {
  new({super.key});

  final List<int> units = [1, 2, 3, 4, 5];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All units')),
      body: ListView.builder(
        itemCount: units.length,
        itemBuilder: (context, index) {
          int unitId = units[index];
          return ListTile(
            title: Text("Unit - $unitId"),
            onTap: () => context.push("/unit/$unitId"),
          );
        },
      ),
    );
  }
}
