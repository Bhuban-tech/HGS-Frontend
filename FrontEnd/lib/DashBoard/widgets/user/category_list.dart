import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';

class CategoryList extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryList({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, i) => _buildCategoryItem(categories[i]),
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> service) {
    final title = service['title'] as String;
    final color = service['color'] as Color;
    final icon = service['icon'] as IconData;
    final isSelected = selectedCategory == title;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onCategorySelected(isSelected ? null : title),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Hero(
                tag: 'category_$title',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [color.withValues(alpha: 0.9), color]
                          : [
                              color.withValues(alpha: 0.15),
                              color.withValues(alpha: 0.05),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: isSelected
                        ? Border.all(color: color, width: 2.5)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : color,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? color : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
