import 'package:flutter/material.dart';

// โมเดลสำหรับรายการอาหารในหน้าเมนู
class FoodItem {
  final String title;
  final String imageUrl;
  final double rating;
  final String duration;
  final double price;

  FoodItem({
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.duration,
    required this.price,
  });
}

// โมเดลสำหรับร้านค้า
class Restaurant {
  final String name;
  final String imageUrl;
  final String type;
  final List<FoodItem> menu;

  Restaurant({
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.menu
  });
}

// โมเดลสำหรับสินค้าในตะกร้า
class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({required this.name, required this.price, required this.quantity});

  // 🟢 เพิ่มฟังก์ชันนี้เพื่อให้บันทึกลง Firebase ได้ง่ายขึ้น
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

// --- ตัวแปร Global สำหรับจัดการสถานะตะกร้า ---

ValueNotifier<List<CartItem>> cartItems = ValueNotifier<List<CartItem>>([]);
ValueNotifier<int> cartItemCount = ValueNotifier<int>(0);
ValueNotifier<double> cartTotalPrice = ValueNotifier<double>(0.0);

ValueNotifier<double> discountAmount = ValueNotifier<double>(0.0);
ValueNotifier<String> selectedPromoLabel = ValueNotifier<String>("เลือกโค้ดส่วนลด");
ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

// ฟังก์ชันอัปเดตยอดรวม (วางไว้นอก Class)
void updateGlobalTotals() {
  cartItemCount.value = cartItems.value.fold(0, (sum, item) => sum + item.quantity);
  cartTotalPrice.value = cartItems.value.fold(0, (sum, item) => sum + (item.price * item.quantity));
}