import 'package:flutter/material.dart';

import '../../home/presentation/home_screens.dart';
import 'shopping_tab.dart';

class ShoppingHomeScreen extends StatelessWidget {
  const ShoppingHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const MainShell(initialIndex: 3);
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: ShoppingTab(initialView: ShoppingView.cart));
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: ShoppingTab(initialView: ShoppingView.checkout));
}

class OrderCompleteScreen extends StatelessWidget {
  const OrderCompleteScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: ShoppingTab(initialView: ShoppingView.complete));
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: ShoppingTab(initialView: ShoppingView.orders));
}
