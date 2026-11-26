import 'package:flutter/widgets.dart';

import '../../features/auth/presentation/auth_screens.dart';
import '../../features/home/presentation/home_detail_screens.dart';
import '../../features/home/presentation/home_screens.dart';
import '../../features/onboarding/presentation/onboarding_screens.dart';
import '../../features/profile/presentation/profile_screens.dart';
import '../../features/records/presentation/records_screens.dart';
import '../../features/shopping/presentation/shopping_screens.dart';
import '../../features/social/presentation/social_screens.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const signUp = '/auth/sign-up';
  static const login = '/auth/login';
  static const passwordRecovery = '/auth/password-recovery';
  static const onboardingProfile = '/onboarding/profile';
  static const onboardingBodyGoal = '/onboarding/body-goal';
  static const home = '/home';
  static const notifications = '/home/notifications';
  static const emptyNotifications = '/home/notifications/empty';
  static const points = '/home/points';
  static const records = '/records';
  static const crew = '/social/crew';
  static const postUpload = '/social/post-upload';
  static const socialFeed = '/social/feed';
  static const crewExplore = '/social/crew-explore';
  static const shopping = '/shopping';
  static const cart = '/shopping/cart';
  static const checkout = '/shopping/checkout';
  static const orderComplete = '/shopping/order-complete';
  static const orders = '/shopping/orders';
  static const profile = '/profile';
  static const bodyMetrics = '/profile/body-metrics';
  static const aiSettings = '/profile/ai-settings';
  static const account = '/profile/account';
  static const address = '/profile/address';
  static const payment = '/profile/payment';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    signUp: (_) => const SignUpScreen(),
    login: (_) => const LoginScreen(),
    passwordRecovery: (_) => const PasswordRecoveryScreen(),
    onboardingProfile: (_) => const ProfileOnboardingScreen(),
    onboardingBodyGoal: (_) => const BodyGoalOnboardingScreen(),
    home: (_) => const HomeDashboardScreen(),
    notifications: (_) => const NotificationsScreen(),
    emptyNotifications: (_) => const NotificationsScreen(empty: true),
    points: (_) => const PointsHistoryScreen(),
    records: (_) => const RecordsScreen(),
    crew: (_) => const CrewScreen(),
    postUpload: (_) => const PostUploadScreen(),
    socialFeed: (_) => const SocialFeedScreen(),
    crewExplore: (_) => const CrewExploreScreen(),
    shopping: (_) => const ShoppingHomeScreen(),
    cart: (_) => const CartScreen(),
    checkout: (_) => const CheckoutScreen(),
    orderComplete: (_) => const OrderCompleteScreen(),
    orders: (_) => const OrdersScreen(),
    profile: (_) => const ProfileScreen(),
    bodyMetrics: (_) => const BodyMetricsScreen(),
    aiSettings: (_) => const AiSettingsScreen(),
    account: (_) => const AccountScreen(),
    address: (_) => const AddressScreen(),
    payment: (_) => const PaymentScreen(),
  };
}
