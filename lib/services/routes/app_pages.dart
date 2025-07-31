import 'package:get/get.dart';
import '../../view/authscreen/auth_screen.dart';
import '../../view/chef/ChefOrder_screen.dart';
import '../../view/chef/chef_dashboard.dart';
import '../../view/chef/chef_menu_page.dart';
import '../../view/chef/chef_profile.dart';
import '../../view/chef/restaurant_setup_screen.dart';
import '../../view/customer/CustomerOrderHistory_screen.dart';
import '../../view/customer/cart_screen.dart';
import '../../view/customer/customer_dashboard.dart';
import '../../view/customer/restaurant_menu_screen.dart';
import '../../view/splash_screen.dart';
import 'app_routs.dart';

final List<GetPage> appPages = [
  GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
  GetPage(name: AppRoutes.auth, page: () => const AuthScreen()),
  GetPage(name: AppRoutes.chefDashboard, page: () => const ChefDashboard()),
  GetPage(name: AppRoutes.customerDashboard, page: () => const CustomerDashboard()),
  GetPage(name: AppRoutes.RestaurantSetupScreen, page: () => const RestaurantSetupScreen()),
  GetPage(name: AppRoutes.ProfilePage, page: () => ProfilePage()),
  GetPage(name: AppRoutes.ChefMenuPage, page: () => const ChefMenuPage()),
  GetPage(
    name: AppRoutes.CustomerRestaurantMenuScreen,
    page: () {
      final args = Get.arguments as Map<String, dynamic>;
      return CustomerRestaurantMenuScreen(
        restaurantId: args['restaurantId'],
        restaurantName: args['restaurantName'],
        restaurantImage: args['restaurantImage'],
        about: args['about'],
      );
    },
  ),
  GetPage(name: AppRoutes.FoodCartScreen, page: () => FoodCartScreen()),
  GetPage(name: AppRoutes.ChefOrdersScreen, page: () => ChefOrdersScreen()),
  GetPage(name: AppRoutes.CustomerOrderHistoryScreen, page: () => CustomerOrderHistoryScreen()),
];
