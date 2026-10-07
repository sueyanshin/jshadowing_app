import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SectionsScreen extends StatelessWidget {
  final int unitId;
  new({super.key, required this.unitId});

  final sectionsList = [
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 5, 6, 7, 8],
    [1, 2, 3, 4, 5, 6, 7, 8],
    [1, 2, 3, 4, 5, 6, 7],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Sections')),
      body: ListView.builder(
        itemCount: sectionsList[unitId - 1].length,
        itemBuilder: (context, index) {
          int sectionId = sectionsList[unitId - 1][index];
          return ListTile(
            title: Text("Section - $sectionId"),
            onTap: () => context.push("/unit/$unitId/section/$sectionId"),
          );
        },
      ),
    );
  }
}
