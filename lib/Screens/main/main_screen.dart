// lib/main/main_screen.dart
import 'package:flutter/material.dart';
import 'package:reel_cart/Screens/explore_screen.dart';
import 'package:reel_cart/Screens/profile_screen.dart';
import 'package:reel_cart/Screens/reels_screen.dart';
import 'package:reel_cart/Screens/cart_screen.dart';
import 'package:reel_cart/Screens/add_product_screen.dart';
import 'package:reel_cart/Screens/vendor_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // نبدأ من شاشة Reels
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _screens = [
    const ExploreScreen(),
    const ReelsScreen(),
    const AddProductScreen(),
    const CartScreen(),
    const ProfileScreen(),
    const VendorProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
        physics: const NeverScrollableScrollPhysics(), // لمنع التمرير الجانبي
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 83,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF94A3B8),
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_rounded),
            label: 'Store',
          ),
        ],
      ),
    );
  }
}
