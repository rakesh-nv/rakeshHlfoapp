import 'package:get/get.dart';
import '../../view/authscreen/auth_screen.dart';
import '../../view/chef/chef_dashboard.dart';
import '../../view/chef/chef_menu_page.dart';
import '../../view/chef/chef_profile.dart';
import '../../view/chef/my_dishes_screen.dart';
import '../../view/chef/restaurant_setup_screen.dart';
import '../../view/customer/customer_dashboard.dart';
import '../../view/splash_screen.dart';
import 'app_routs.dart';
final List<GetPage> appPages = [
  GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
  GetPage(name: AppRoutes.auth, page: () => AuthScreen()),
  GetPage(name: AppRoutes.chefDashboard, page: () => ChefDashboard()),
  GetPage(name: AppRoutes.customerDashboard, page: () => CustomerDashboard()),
  GetPage(name: AppRoutes.RestaurantSetupScreen, page: () => RestaurantSetupScreen()),
  GetPage(name: AppRoutes.ProfilePage, page: () => ProfilePage(),),
  GetPage(name: AppRoutes.ChefMenuPage, page: () => ChefMenuPage(),),
  // GetPage(name: AppRoutes.MyDishesScreen, page: () => MyDishesScreen(),),
  // GetPage(name: AppRoutes.AddFoodScreen, page: () => AddFoodScreen(),)

];
