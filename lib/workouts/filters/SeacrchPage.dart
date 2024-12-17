// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../BottomBar.dart';
// import 'package:flutter/material.dart';
//
// import '../WorkoutPage.dart';
// import '../components/ProgramCard.dart';
//
// class ProgramsPage extends StatefulWidget {
//   @override
//   _ProgramsPageState createState() => _ProgramsPageState();
// }
//
// class _ProgramsPageState extends State<ProgramsPage> {
//   String searchQuery = ''; // Змінна для зберігання пошукового запиту
//   List<Map<String, dynamic>> programsList = []; // Список для зберігання всіх програм
//
//   // Функція для завантаження всіх програм з Firestore
//   Future<void> loadPrograms() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance.collection('programs').get();
//       final programs = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//       setState(() {
//         programsList = programs; // Зберігаємо всі програми у локальний список
//       });
//     } catch (e) {
//       print('Error loading programs: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     loadPrograms(); // Завантажуємо програми при ініціалізації
//   }
//
//   // Функція для фільтрації програм за пошуковим запитом
//   List<Map<String, dynamic>> filterPrograms(String query) {
//     return programsList.where((program) {
//       final title = program['title']?.toLowerCase() ?? '';
//       return title.contains(query.toLowerCase()); // Фільтруємо за назвою
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6EFFF), // Колір фону
//       body: Column(
//         children: [
//           const SizedBox(height: 48.0),
//           const Text(
//             'Programs',
//             style: TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 24,
//               fontFamily: 'Montserrat',
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Пошукове поле перше
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Container(
//                     width: 300, // Встановлюємо ширину
//                     height: 50, // Встановлюємо висоту
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: 'Search...',
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           searchQuery = value; // Оновлюємо запит пошуку
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 // Іконка сортування
//                 IconButton(
//                   icon: const Icon(Icons.sort, color: Colors.black),
//                   onPressed: () {
//                     // Обробка сортування
//                   },
//                 ),
//                 // Іконка фільтра
//                 IconButton(
//                   icon: const Icon(Icons.filter_list, color: Colors.black),
//                   onPressed: () {
//                     // Обробка фільтра
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: programsList.isEmpty
//                 ? const Center(child: CircularProgressIndicator()) // Показуємо індикатор завантаження, поки програми не завантажені
//                 : ListView.builder(
//               itemCount: filterPrograms(searchQuery).length,
//               itemBuilder: (context, index) {
//                 final program = filterPrograms(searchQuery)[index];
//
//                 return ProgramCard(
//                   title: program['title'] ?? 'No Title',
//                   year: program['year']?.toString() ?? 'Unknown',
//                   imageUrl: program['imageUrl'] ?? 'https://via.placeholder.com/150',
//                   gradColor: program['gradColor'],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       // bottomNavigationBar: CustomBottomNav(
//       //   currentIndex: _currentIndex,
//       //   onTap: _onNavTap,
//       // ),
//     );
//   }
// }
