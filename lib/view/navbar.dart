import 'package:flutter/material.dart';

import 'common_widgets/customer_app_bar.dart';
import 'customer/CustomerOrderHistory_screen.dart';
import 'customer/cart_screen.dart';
import 'customer/customer_profile_page.dart';
import 'customer/restaurant_list_screen.dart';
import 'package:get/get.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const RestaurantListScreen(),
    const FoodCartScreen(),
    const CustomerOrderHistoryScreen(),
  ];

  void onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0; // Always go back to Restaurant screen first
          });
          return false; // Prevent app from exiting immediately
        }
        return true; // Allow app to close when already on Restaurant
      },
      child: Scaffold(
        appBar: CommonAppBar(
          title: _getAppBarTitle(_currentIndex),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    // Navigate to profile page
                    Get.to(() => const CustomerProfilePage());
                  },
                ),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        // bottomNavigationBar: Theme(
        //   data: Theme.of(context).copyWith(
        //     splashFactory: NoSplash.splashFactory,
        //     highlightColor: Colors.transparent,
        //   ),
        //   child: BottomNavigationBar(
        //     type: BottomNavigationBarType.fixed,
        //     selectedItemColor: Colors.deepOrange,
        //     unselectedItemColor: Colors.grey,
        //     showSelectedLabels: true,
        //     enableFeedback: false,
        //     onTap: onTabTapped,
        //     currentIndex: _currentIndex,
        //     items: const [
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.restaurant_menu),
        //         label: 'Restaurants',
        //       ),
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.shopping_cart_outlined),
        //         label: 'Cart',
        //       ),
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.history),
        //         label: 'Orders',
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Restaurants';
      case 1:
        return 'Your Cart';
      case 2:
        return 'Order History';
      default:
        return 'App';
    }
  }
}
