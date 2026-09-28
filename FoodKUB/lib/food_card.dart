import 'package:flutter/material.dart';
import 'models.dart';
import 'food_detail_screen.dart';

class FoodCard extends StatelessWidget {
  final FoodItem food;
  const FoodCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      // เอาสีขาวออกเพื่อให้เห็นขอบเขตชัดเจน หรือใส่พื้นหลังอ่อนๆ
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 🟢 แก้ที่ 1: ให้ Column ใช้พื้นที่เท่าที่จำเป็น
        children: [
          // ส่วนรูปภาพ
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  food.imageUrl,
                  height: 120, // 🟢 แก้ที่ 2: ลดความสูงรูปภาพลงนิดนึง
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.whatshot, color: Colors.red, size: 12),
                      Text(" ขายดี", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // ระยะห่างระหว่างรูปกับชื่อ

          // ชื่อเมนู
          Text(
            food.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4), // 🟢 แก้ที่ 3: ใช้ระยะห่างคงที่ แทนการใช้ Spacer()

          // ส่วนราคาและปุ่มบวก
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "฿${food.price.toInt()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
                  );
                },
                child: Container(
                  width: 28, // 🟢 แก้ที่ 4: ปรับขนาดปุ่มให้กะทัดรัดขึ้น
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00A344),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}