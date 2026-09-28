import 'package:flutter/material.dart';
import 'models.dart';

class PromoCodeScreen extends StatelessWidget {
  const PromoCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double currentTotal = cartTotalPrice.value;

    return Scaffold(
      appBar: AppBar(title: const Text("โค้ดส่วนลดของฉัน")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // โค้ดส่วนลด 20 บาท เมื่อครบ 120
          _buildPromoTile(
            context,
            title: "ส่วนลด 20 บาท",
            subtitle: "เมื่อสั่งขั้นต่ำ ฿120",
            isEnabled: currentTotal >= 120,
            onTap: () {
              discountAmount.value = 20.0;
              selectedPromoLabel.value = "ลด ฿20 (ขั้นต่ำ ฿120)";
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),

          // โค้ดส่งฟรี (สมมติว่าค่าส่งคือ 25 บาท)
          _buildPromoTile(
            context,
            title: "ส่งฟรี",
            subtitle: "รับส่วนลดค่าจัดส่ง ฿25",
            isEnabled: true, // เลือกได้ตลอดหรือตามเงื่อนไขที่คุณต้องการ
            onTap: () {
              discountAmount.value = 25.0; // สมมติว่าลดเท่าค่าส่ง
              selectedPromoLabel.value = "ส่งฟรี";
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoTile(BuildContext context, {required String title, required String subtitle, required bool isEnabled, required VoidCallback onTap}) {
    return ListTile(
      enabled: isEnabled,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      leading: Icon(Icons.confirmation_number, color: isEnabled ? const Color(0xFF00A344) : Colors.grey),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isEnabled ? Colors.black : Colors.grey)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}