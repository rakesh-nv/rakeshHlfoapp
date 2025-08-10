import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../chef/chef_profile.dart';
import 'CustomerOrderHistory_screen.dart';
import 'cart_screen.dart';
import 'restaurant_list_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Restaurants";
      case 1:
        return "Your Cart";
      case 2:
        return "Your Profile";
      case 3:
        return "Order History";
      default:
        return "Dashboard";
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      _onTabTapped(0); // Go to Restaurants tab
      return false; // Prevent default back action
    }
    return true; // Allow app to close or navigate back normally
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // No AppBar as requested
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const RestaurantListScreen(),
            const FoodCartScreen(),
            ProfilePage(),
            const CustomerOrderHistoryScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: Colors.deepOrange,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Restaurants',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }
}
