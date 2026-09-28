import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("ประวัติการสั่งซื้อ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: user == null
          ? const Center(child: Text("กรุณาเข้าสู่ระบบ"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("ยังไม่มีประวัติการสั่งซื้อ"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // 🟢 คำนวณเวลาเพื่อเปลี่ยนสถานะอัตโนมัติ
              var timestamp = order['timestamp'] as Timestamp?;
              DateTime now = DateTime.now();
              DateTime orderTime = timestamp?.toDate() ?? now;
              int differenceInMinutes = now.difference(orderTime).inMinutes;

              // เงื่อนไข: ถ้าเกิน 5 นาที ให้เป็น 'สำเร็จ' ถ้าไม่ถึงให้เป็น 'กำลังเตรียมอาหาร'
              String statusText = differenceInMinutes >= 5 ? "สำเร็จ" : "กำลังเตรียมอาหาร";
              Color statusColor = differenceInMinutes >= 5 ? Colors.green : Colors.orange;

              String dateStr = timestamp != null
                  ? DateFormat('dd MMM yyyy, HH:mm').format(orderTime)
                  : "ไม่ระบุเวลา";

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),

                          // 🟢 แสดงสถานะที่เปลี่ยนตามเวลาอัตโนมัติ
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      if (order['items'] != null)
                        ...(order['items'] as List).map((item) {
                          String displayText = "";
                          if (item is Map) {
                            displayText = "${item['quantity'] ?? 1}x ${item['name'] ?? 'ไม่มีชื่อ'}";
                          } else {
                            displayText = item.toString();
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(displayText, style: const TextStyle(fontSize: 14)),
                                ),
                              ],
                            ),
                          );
                        }),

                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("ราคารวมทั้งหมด", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "฿${order['totalPrice'] ?? '0'}",
                            style: const TextStyle(
                                color: Color(0xFF00B14F),
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                                order['address'] ?? 'ไม่มีข้อมูลที่อยู่',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}