import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'models.dart';
import 'login_screen.dart';
import 'map_picker_screen.dart';
import 'order_history_screen.dart'; // 🟢 Import มาเพื่อให้เรียกหน้าประวัติได้

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // อัปเดตข้อมูลผู้ใช้ลง Firebase
  Future<void> _updateUserData(String field, String newValue) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({field: newValue});
    }
  }

  // เลือกที่อยู่จากแผนที่
  Future<void> _pickAddressFromMap() async {
    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (pickedLocation != null) {
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
      try {
        await setLocaleIdentifier("th_TH");
        List<Placemark> placemarks = await placemarkFromCoordinates(
          pickedLocation.latitude,
          pickedLocation.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String formattedAddress = "${place.street ?? ''} ${place.subLocality ?? ''} ${place.locality ?? ''} ${place.postalCode ?? ''}".trim();
          await _updateUserData("address", formattedAddress);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
      } finally {
        Navigator.pop(context);
      }
    }
  }

  // หน้าต่าง BottomSheet สำหรับแก้ไขข้อมูล
  void _showEditSheet(String title, String field, String currentVal) {
    TextEditingController controller = TextEditingController(text: currentVal);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("แก้ไข $title", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            if (field == "address")
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _pickAddressFromMap();
                },
                leading: const Icon(Icons.map, color: Colors.blue),
                title: const Text("เลือกตำแหน่งบนแผนที่", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: field == "address" ? 3 : 1,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "กรอก $title ใหม่",
                suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => controller.clear()),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B14F)),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    _updateUserData(field, controller.text);
                  }
                  Navigator.pop(context);
                },
                child: const Text("บันทึกข้อมูล", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("โปรไฟล์ของฉัน", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Center(child: Text("กรุณาเข้าสู่ระบบ"))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("เกิดข้อผิดพลาด"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("ไม่พบข้อมูลผู้ใช้"));

          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
          String name = userData['name'] ?? 'ไม่มีชื่อ';
          String email = userData['email'] ?? currentUser.email ?? 'ไม่มีอีเมล';
          String phone = userData['phone'] ?? 'ไม่มีเบอร์โทร';
          String address = userData['address'] ?? 'ไม่มีที่อยู่';

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildProfileAvatar(name),
                const SizedBox(height: 15),
                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                _buildInfoTile(Icons.person_outline, "ชื่อผู้ใช้", name, () => _showEditSheet("ชื่อผู้ใช้", "name", name)),
                _buildInfoTile(Icons.email_outlined, "อีเมล", email, () => _showEditSheet("อีเมล", "email", email)),
                _buildInfoTile(Icons.phone_iphone, "เบอร์โทรศัพท์", phone, () => _showEditSheet("เบอร์โทรศัพท์", "phone", phone)),
                _buildInfoTile(Icons.location_on_outlined, "ที่อยู่เริ่มต้น", address, () => _showEditSheet("ที่อยู่เริ่มต้น", "address", address)),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(),
                ),

                // 🟢 ปุ่มไปหน้าประวัติการสั่งซื้อ
                _buildMenuTile(Icons.history, "ประวัติการสั่งซื้อ", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
                }),

                const SizedBox(height: 30),
                _buildLogoutButton(context),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget สำหรับปุ่มเมนูทั่วไป
  Widget _buildMenuTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String name) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Icon(Icons.person, size: 80, color: Colors.green),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.edit_note, size: 22, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity, height: 50,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            // เช็คว่ามีตัวแปรเหล่านี้ใน models.dart หรือไฟล์อื่นที่เชื่อมไว้ไหมนะครับ
            try {
              isLoggedIn.value = false;
              cartItems.value = [];
              updateGlobalTotals();
            } catch (e) {
              print("Global variables error: $e");
            }
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            }
          },
          child: const Text("ออกจากระบบ", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}