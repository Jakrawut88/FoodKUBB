import 'package:flutter/material.dart';
import 'models.dart';
import 'food_card.dart';
import 'profile_screen.dart'; // 🟢 1. เปลี่ยนจาก login_screen เป็น profile_screen
import 'cart_bottom_bar.dart';

class HomeScreen extends StatelessWidget {
  final Restaurant restaurant;

  const HomeScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(restaurant.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                // 🟢 2. แก้จุดนี้ครับ! เปลี่ยนจาก LoginScreen เป็น ProfileScreen
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen())
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.red,
            labelColor: Color(0xFF00A344),
            tabs: [Tab(text: "เมนูดัง")],
          ),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 15,
            mainAxisSpacing: 20,
          ),
          itemCount: restaurant.menu.length,
          itemBuilder: (context, index) => FoodCard(food: restaurant.menu[index]),
        ),
        bottomNavigationBar: const CartBottomBar(),
      ),
    );
  }
}