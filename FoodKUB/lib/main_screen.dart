import 'package:flutter/material.dart';
import 'models.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  final List<Restaurant> restaurants = [
    Restaurant(
      name: "แซ่บอีหลี ส้มตำ",
      type: "อาหารอีสาน",
      imageUrl: "assets/images/somtum.jpg",
      menu: [
        FoodItem(title: "ส้มตำไทย", imageUrl: "assets/images/somtum.jpg", rating: 4.8, duration: "10 min", price: 50),
        FoodItem(title: "ไก่ย่าง", imageUrl: "assets/images/chicken.jpg", rating: 4.9, duration: "15 min", price: 60),
      ],
    ),
    Restaurant(
      name: "ปังปิ้ง หอมกรุ่น",
      type: "ขนมหวาน",
      imageUrl: "assets/images/bread.jpg",
      menu: [
        FoodItem(title: "ขนมปังเนยนม", imageUrl: "assets/images/bread.jpg", rating: 4.7, duration: "5 min", price: 35),
      ],
    ),
    Restaurant(
      name: "ครัวป้าใจ ตามสั่ง",
      type: "อาหารจานเดียว",
      imageUrl: "assets/images/basil.jpg",
      menu: [
        FoodItem(title: "กะเพราไข่ดาว", imageUrl: "assets/images/basil.jpg", rating: 4.6, duration: "10 min", price: 60),
      ],
    ),
    Restaurant(
      name: "พิซซ่านี้อร่อยสุดๆ",
      type: "พิซซ่า/เบอร์เกอร์",
      imageUrl: "assets/images/burger.jpg",
      menu: [
        FoodItem(title: "Classic Burger", imageUrl: "assets/images/burger.jpg", rating: 4.8, duration: "15 min", price: 189),
        FoodItem(title: "Pepperoni Pizza", imageUrl: "assets/images/pizza.jpg", rating: 4.5, duration: "30 min", price: 329),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เลือกสั่งอาหาร FoodKUB", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final shop = restaurants[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(restaurant: shop))),
            child: Card(
              margin: const EdgeInsets.only(bottom: 15),
              child: Column(
                children: [
                  Image.asset(shop.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.store)),
                  ),
                  ListTile(
                    title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(shop.type),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}