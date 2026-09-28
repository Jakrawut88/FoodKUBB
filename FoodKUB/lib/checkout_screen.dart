import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'models.dart';
import 'map_picker_screen.dart'; // อย่าลืม import ไฟล์หน้าแผนที่

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String currentAddress = "กำลังโหลด...";
  String currentContact = "";
  int deliveryFee = 25;
  bool isLoading = true;
  bool isLocating = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          currentAddress = doc.data()?['address'] ?? "ไม่มีที่อยู่";
          currentContact = "${doc.data()?['name'] ?? ''} - ${doc.data()?['phone'] ?? ''}";
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveOrderToHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    List<Map<String, dynamic>> orderItems = cartItems.value.map((item) => item.toMap()).toList();

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': user.uid,
      'items': orderItems,
      'totalPrice': cartTotalPrice.value + deliveryFee,
      'address': currentAddress,
      'status': 'กำลังเตรียมอาหาร',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 1️⃣ ระบบ: ใช้ตำแหน่งปัจจุบัน
  Future<void> _getCurrentLocation(StateSetter modalState) async {
    modalState(() => isLocating = true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      await _updateAddressFromLatLng(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    } finally {
      modalState(() => isLocating = false);
    }
  }

  // 2️⃣ ระบบ: เลือกบนแผนที่
  Future<void> _pickOnMap(StateSetter modalState) async {
    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (pickedLocation != null) {
      modalState(() => isLocating = true);
      await _updateAddressFromLatLng(pickedLocation.latitude, pickedLocation.longitude);
      modalState(() => isLocating = false);
    }
  }

  // ฟังก์ชันช่วยแปลงพิกัดเป็นชื่อที่อยู่
  Future<void> _updateAddressFromLatLng(double lat, double lng) async {
    await setLocaleIdentifier("th_TH");
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String formatted = "${place.street ?? ''} ${place.subLocality ?? ''} ${place.locality ?? ''} ${place.postalCode ?? ''}".trim();
      setState(() => currentAddress = formatted);
    }
  }

  void _showEditAddressSheet() {
    TextEditingController addressController = TextEditingController(text: currentAddress == "ไม่มีที่อยู่" ? "" : currentAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, modalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("ระบุที่อยู่จัดส่ง", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // ปุ่มแบบที่ 1: ตำแหน่งปัจจุบัน
              ListTile(
                onTap: isLocating ? null : () async {
                  await _getCurrentLocation(modalState);
                  addressController.text = currentAddress;
                },
                leading: const Icon(Icons.my_location, color: Colors.blue),
                title: Text(isLocating ? "กำลังดึงพิกัด..." : "ใช้ตำแหน่งปัจจุบันของคุณ", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),

              // ปุ่มแบบที่ 2: เปิดแผนที่
              ListTile(
                onTap: isLocating ? null : () async {
                  await _pickOnMap(modalState);
                  addressController.text = currentAddress;
                },
                leading: const Icon(Icons.map_outlined, color: Colors.orange),
                title: const Text("เลือกตำแหน่งบนแผนที่", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 10),
              TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "รายละเอียดที่อยู่", border: OutlineInputBorder())
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B14F)),
                  onPressed: () async {
                    setState(() => currentAddress = addressController.text);
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'address': addressController.text});
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("บันทึกที่อยู่", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- ส่วนประกอบ UI อื่นๆ (คงเดิมจากที่คุณให้มา) ---
  void _showSuccessDialog() async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await _saveOrderToHistory();
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text("สั่งซื้อสำเร็จ!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B14F)),
                onPressed: () {
                  cartItems.value = [];
                  updateGlobalTotals();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("กลับสู่หน้าหลัก", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  bool get isReadyToOrder => currentAddress != "ไม่มีที่อยู่" && currentAddress.isNotEmpty && cartItems.value.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("สรุปคำสั่งซื้อ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Column(
          children: [
            _buildAddressSection(),
            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
            _buildOrderItemsSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAddressSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ที่อยู่การจัดส่ง", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentAddress, style: TextStyle(fontWeight: FontWeight.bold, color: currentAddress == "ไม่มีที่อยู่" ? Colors.red : Colors.black)),
                    Text(currentContact, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              TextButton(onPressed: _showEditAddressSheet, child: const Text("แก้ไข", style: TextStyle(color: Colors.green))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("รายการอาหารที่สั่ง", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          ValueListenableBuilder(
            valueListenable: cartItems,
            builder: (context, List<CartItem> items, child) {
              return Column(
                children: items.asMap().entries.map((entry) {
                  int index = entry.key;
                  CartItem item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                          child: Text("${item.quantity}"),
                        ),
                        const SizedBox(width: 15),
                        Expanded(child: Text(item.name)),
                        Text("฿${(item.price * item.quantity).toInt()}"),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () {
                          setState(() {
                            cartItems.value.removeAt(index);
                            updateGlobalTotals();
                            cartItems.notifyListeners();
                          });
                        })
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const Divider(),
          _buildPriceRow("ยอดรวมอาหาร", "฿${cartTotalPrice.value.toInt()}"),
          _buildPriceRow("ค่าจัดส่ง", "฿$deliveryFee"),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isReadyToOrder)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text("⚠️ กรุณาระบุที่อยู่และเลือกอาหาร", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isReadyToOrder ? const Color(0xFF00B14F) : Colors.grey[400],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: isReadyToOrder ? _showSuccessDialog : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("สั่งเลย", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("฿${(cartTotalPrice.value + deliveryFee).toInt()}", style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(price, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}