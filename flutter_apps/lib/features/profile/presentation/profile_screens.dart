import 'package:flutter/widgets.dart';

import '../../home/presentation/home_screens.dart';
import 'profile_tab.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const MainShell(initialIndex: 4);
}

class BodyMetricsScreen extends StatelessWidget {
  const BodyMetricsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const ProfileTab(initialView: ProfileView.metrics);
}

class AiSettingsScreen extends StatelessWidget {
  const AiSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const ProfileTab(initialView: ProfileView.ai);
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const ProfileTab(initialView: ProfileView.account);
}

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const ProfileTab(initialView: ProfileView.address);
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const ProfileTab(initialView: ProfileView.payment);
}
