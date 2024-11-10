import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/appbar.dart';
import '../components/bottom_bar.dart';
import '../components/add_button.dart';
import '../components/emoji_picker_dialog.dart';
import '../constants.dart';
import '../models/category.dart';
import '../controllers/category_controller.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final CategoryController _categoryController = CategoryController();
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _categoryController.init(); // Ensure box is opened
    setState(() {
      categories = _categoryController.getCategories();
      print('Categories: $categories');
    });
  }

  Future<void> _addCategory(Category category) async {
    await _categoryController.addCategory(category); // Ensure save completes
    setState(() {
      categories = _categoryController.getCategories(); // Fetch latest list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: backgroundColor,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/categories.svg',
                color: Colors.white,
              ),
              Text(
                " Categories",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: boxColor,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    print('Category ${category.name} tapped');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.emoji ?? '😀',
                          style: TextStyle(fontSize: 50),
                        ),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ]),
      floatingActionButton: AddButton(
        onPressed: () async {
          final category = await showDialog<Category>(
            context: context,
            builder: (context) => AddCategoryDialog(),
          );
          if (category != null) {
            _addCategory(
                category); // Save the category using CategoryController
          }
        },
      ),
      bottomNavigationBar: BottomBar(),
    );
  }

  @override
  void dispose() {
    _categoryController.closeBox();
    super.dispose();
  }
}

class AddCategoryDialog extends StatefulWidget {
  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  String selectedEmoji = '😀'; // Default emoji
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  "Add category",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                IconButton(
                  icon: Icon(Icons.check, color: Colors.white),
                  onPressed: () {
                    // Check if name is entered
                    if (_nameController.text.isNotEmpty) {
                      // Create a new Category instance
                      final newCategory = Category(
                        name: _nameController.text,
                        emoji: selectedEmoji,
                      );
                      // Pass the new category back to the calling context
                      Navigator.of(context).pop(newCategory);
                    } else {
                      // Show an alert if the name is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please enter a category name."),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Choose an icon:",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final emoji = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return EmojiPickerDialog();
                  },
                );
                if (emoji != null) {
                  setState(() {
                    selectedEmoji = emoji;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedEmoji,
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Name...",
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: boxColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
