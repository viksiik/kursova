import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../BottomBar.dart';
import '../profile/ProfilePage.dart';
import '../program/MainPage.dart';
import 'DaysPage.dart';
import 'components/ProgramCard.dart';
import 'filters/SeacrchPage.dart';

class MainWorkoutPage extends StatefulWidget {
  const MainWorkoutPage({super.key});

  @override
  _MainWorkoutPageState createState() => _MainWorkoutPageState();
}

class _MainWorkoutPageState extends State<MainWorkoutPage> {
  int _currentIndex = 1;
  String searchQuery = '';
  List<Map<String, dynamic>> programsList = [];
  List<Map<String, dynamic>> originalProgramsList = []; // Зберігає повний список програм
  bool isSorted = false; // Змінна для збереження стану сортування

  String? selectedCategory; // Обрана категорія
  String? selectedDifficulty; // Обрана складність
  bool filtersApplied = false; // Чи є застосовані фільтри

  Future<void> loadPrograms() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('programs').get();
      final programs = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      setState(() {
        programsList = programs;
        originalProgramsList = List.from(programs); // Зберігаємо оригінал
      });
    } catch (e) {
      print('Error loading programs: $e');
    }
  }

  // Функція для скидання сортування
  void resetSort() {
    setState(() {
      isSorted = false; // Встановлюємо, що сортування скинуте
    });
    loadPrograms(); // Перезавантажуємо програми з Firestore
  }

  List<Map<String, dynamic>> filterPrograms(String query) {
    return programsList.where((program) {
      return program['title'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadPrograms();
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserProfilePage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void sortProgramsBy(String criteria, String order) {
    setState(() {
      if (criteria == 'year') {
        programsList.sort((a, b) {
          int yearA = (a['year'] is String) ? int.parse(a['year']) : a['year'];
          int yearB = (b['year'] is String) ? int.parse(b['year']) : b['year'];
          return order == 'asc' ? yearA.compareTo(yearB) : yearB.compareTo(yearA);
        });
      } else if (criteria == 'title') {
        programsList.sort((a, b) {
          String titleA = a['title'] ?? '';
          String titleB = b['title'] ?? '';
          return order == 'asc'
              ? titleA.compareTo(titleB)
              : titleB.compareTo(titleA);
        });
      }
      isSorted = true; // Оновлюємо статус сортування
    });
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Year (Ascending)'),
                onTap: () {
                  sortProgramsBy('year', 'asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Sort by Year (Descending)'),
                onTap: () {
                  sortProgramsBy('year', 'desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Sort by Title (Ascending)'),
                onTap: () {
                  sortProgramsBy('title', 'asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Sort by Title (Descending)'),
                onTap: () {
                  sortProgramsBy('title', 'desc');
                  Navigator.pop(context);
                },
              ),
              // Додаємо кнопку для скидання сортування
              ListTile(
                title: const Text('Reset Sorting'),
                onTap: () {
                  resetSort(); // Скидаємо сортування
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Programs',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat'
                ),
              ),
              const SizedBox(height: 10),
              const Text('Category:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat'
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: ['abs', 'full body', 'lower body']
                    .map((category) => ChoiceChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  onSelected: (isSelected) {
                    setState(() {
                      selectedCategory = isSelected ? category : null;
                    });
                    applyFilters();
                  },
                ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              const Text('Difficulty:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat'
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: ['beginner', 'intermediate', 'advanced']
                    .map((difficulty) => ChoiceChip(
                  label: Text(difficulty),
                  selected: selectedDifficulty == difficulty,
                  onSelected: (isSelected) {
                    setState(() {
                      selectedDifficulty =
                      isSelected ? difficulty : null;
                    });
                    applyFilters();
                  },
                ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  resetFilters();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.clear),
                label: const Text('Reset Filters'),
              ),
            ],
          ),
        );
      },
    );
  }


  void resetFilters() {
    setState(() {
      selectedCategory = null;
      selectedDifficulty = null;
      programsList = List.from(originalProgramsList);
      filtersApplied = false;
    });
  }

  void applyFilters() {
    setState(() {
      programsList = originalProgramsList.where((program) {
        final matchesCategory = selectedCategory == null ||
            program['category']?.toLowerCase() == selectedCategory!.toLowerCase();
        final matchesDifficulty = selectedDifficulty == null ||
            program['difficulty']?.toLowerCase() ==
                selectedDifficulty!.toLowerCase();

        return matchesCategory && matchesDifficulty;
      }).toList();

      // Перевірка, чи є застосовані фільтри
      filtersApplied = selectedCategory != null || selectedDifficulty != null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFFF),
      body: Column(
        children: [
          const SizedBox(height: 48.0),
          const Text(
            'Programs',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              fontFamily: 'Montserrat',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Пошукове поле
                Container(
                  width: 280,
                  height: 36,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      hintStyle: TextStyle(
                        fontFamily: 'Montserrat',
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                // Іконка сортування
                IconButton(
                  icon: Icon(
                    Icons.sort,
                    color: isSorted ? Colors.black : Colors.grey, // Змінюємо колір іконки
                  ),
                  onPressed: _showSortMenu,
                ),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: filtersApplied ? Colors.black : Colors.grey,
                  ),
                  onPressed: _showFilterMenu,
                ),

              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('programs')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching data!'),
                  );
                }

                final programs = snapshot.data?.docs ?? [];

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: filterPrograms(searchQuery).length,
                  itemBuilder: (context, index) {
                    final program = filterPrograms(searchQuery)[index];
                    final data = program;

                    return ProgramCard(
                      title: data['title'] ?? 'No Title',
                      year: data['year']?.toString() ?? 'Unknown',
                      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
                      gradColor: data['gradColor'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WeightLossProgram(workoutName: data['title'], workoutUrl: data['imageUrl'],),
                          ),
                        );
                      }
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

