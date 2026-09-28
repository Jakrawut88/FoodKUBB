import 'package:flutter/material.dart';
import 'models.dart';
import 'checkout_screen.dart'; // 1. อย่าลืม Import หน้าจ่ายเงิน

class CartBottomBar extends StatelessWidget {
  const CartBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ ValueListenableBuilder เพื่อดึงค่าจากตะกร้าส่วนกลาง (Global State)
    return ValueListenableBuilder(
      valueListenable: cartItemCount,
      builder: (context, count, child) {
        // 2. ถ้าในตะกร้าไม่มีของ (count เป็น 0) ไม่ต้องแสดงแถบนี้
        if (count == 0) return const SizedBox.shrink();

        return GestureDetector(
          // 3. เมื่อกดที่แถบสีเขียว ให้เด้งไปหน้า CheckoutScreen
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CheckoutScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20), // เว้นระยะล่างกันหน้าจอไอโฟน
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF00A344), // สีเขียว Grab/LineMan
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // วงกลมเลขจำนวนอาหาร
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$count",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ข้อความตะกร้าของฉัน
                  const Text(
                    "ตะกร้าของฉัน",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(), // ดันราคาไปทางขวาสุด

                  // ยอดเงินรวม
                  Text(
                    "฿${cartTotalPrice.value.toInt()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}