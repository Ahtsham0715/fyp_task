import 'package:cloud_firestore/cloud_firestore.dart';

Future<List> getdepartments() async {
  List<String> departments = [];
  await FirebaseFirestore.instance
      .collection('departments')
      .get()
      .then((QuerySnapshot deps) {
    for (var dep in deps.docs) {
      departments.add(dep['department_name']);
    }
    // print(departments);
  });
  return departments;
}
