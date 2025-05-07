// File: lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import '../pages/main_menu.dart';
import '../pages/team_members_page.dart';
import '../pages/help_page.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key, 
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Beranda'),
              _buildNavItem(1, Icons.group, 'Anggota'),
              _buildNavItem(2, Icons.help, 'Bantuan'),
            ],
          ),
        ),
        // Floating circle for selected item
        if (widget.currentIndex >= 0 && widget.currentIndex <= 2)
          Positioned(
            top: -20,
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(
                    (widget.currentIndex - 1) * MediaQuery.of(context).size.width / 3,
                    0,
                  ),
                  child: Transform.scale(
                    scale: value,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFF6A11CB),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF6A11CB).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        widget.currentIndex == 0 
                            ? Icons.home 
                            : widget.currentIndex == 1 
                                ? Icons.group 
                                : Icons.help,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = widget.currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          _animationController.reset();
          _animationController.forward();
          widget.onTap(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty space to prevent overlapping with floating circle
            isSelected 
                ? SizedBox(height: 26) 
                : SizedBox(
                    height: 26,
                    child: Icon(
                      icon,
                      color: Colors.grey,
                      size: 22,
                    ),
                  ),
            SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected ? Color(0xFF6A11CB) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isSelected ? 12 : 11,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}