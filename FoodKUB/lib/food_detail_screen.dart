import 'package:flutter/material.dart';
import 'models.dart';
import 'profile_screen.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem food;
  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int quantity = 1;
  double basePrice = 0;

  // --- ตัวแปรสำหรับเมนูทั่วไป ---
  String? selectedOption;
  List<String> availableOptions = [];

  // --- ตัวแปรพิเศษสำหรับ Classic Burger ---
  String selectedDoneness = "Medium Rare";
  Map<String, bool> burgerToppings = {
    "เพิ่มชีส (+15)": false,
    "เพิ่มเบคอน (+20)": false,
    "เพิ่มไข่ดาว (+10)": false,
  };

  // --- 🍕 ตัวแปรพิเศษสำหรับ Pizza (LINEMAN Style) ---
  String selectedCrust = "หนานุ่ม"; // เลือกแป้ง (Radio)
  Map<String, bool> pizzaToppings = {
    "เพิ่มชีส (+30)": false,
    "เพิ่มเปปเปอโรนี (+40)": false,
    "เพิ่มสับปะรด (+20)": false,
  };

  @override
  void initState() {
    super.initState();
    basePrice = widget.food.price;
    _initializeOptions();
  }

  void _initializeOptions() {
    if (widget.food.title.contains("ส้มตำ")) {
      availableOptions = ["เผ็ดน้อย", "เผ็ดกลาง", "เผ็ดมาก"];
      selectedOption = "เผ็ดกลาง";
    } else if (!widget.food.title.contains("Burger") && !widget.food.title.contains("Pizza")) {
      availableOptions = ["ธรรมดา", "พิเศษ (+10)"];
      selectedOption = "ธรรมดา";
    }
  }

  // คำนวณราคาส่วนเพิ่ม
  double get _currentAddonPrice {
    double addon = 0;

    if (widget.food.title.contains("Burger")) {
      burgerToppings.forEach((key, value) {
        if (value) {
          if (key.contains("+20")) addon += 20;
          else if (key.contains("+15")) addon += 15;
          else if (key.contains("+10")) addon += 10;
        }
      });
    } else if (widget.food.title.contains("Pizza")) {
      // 🟢 คิดราคาขอบพิเศษ และ Topping ของ Pizza
      if (selectedCrust.contains("+40")) addon += 40;
      pizzaToppings.forEach((key, value) {
        if (value) {
          if (key.contains("+40")) addon += 40;
          else if (key.contains("+30")) addon += 30;
          else if (key.contains("+20")) addon += 20;
        }
      });
    } else {
      if (selectedOption != null && selectedOption!.contains("+10")) addon = 10;
    }
    return addon;
  }

  @override
  Widget build(BuildContext context) {
    bool isBurger = widget.food.title.contains("Burger");
    bool isPizza = widget.food.title.contains("Pizza");
    double finalUnitPrice = basePrice + _currentAddonPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.food.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Image.asset(
                  widget.food.imageUrl,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, e, s) => Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 100)),
                ),

                // 🟢 แสดงผลตามประเภทอาหาร
                if (isPizza) ...[
                  // --- ส่วนของ Pizza (แบบ LINEMAN) ---
                  _buildSectionHeader("เลือกแป้งและขอบ (เลือก 1 อย่าง)", isRequired: true),
                  ...["หนานุ่ม", "บางกรอบ", "ขอบชีส (+40)"].map((val) => RadioListTile<String>(
                    title: Text(val),
                    value: val,
                    groupValue: selectedCrust,
                    activeColor: Colors.green,
                    onChanged: (v) => setState(() => selectedCrust = v!),
                  )),
                  _buildSectionHeader("เพิ่มเครื่องหน้า (ติ๊กได้หลายอย่าง)", isRequired: false),
                  ...pizzaToppings.keys.map((key) => CheckboxListTile(
                    title: Text(key),
                    value: pizzaToppings[key],
                    activeColor: Colors.green,
                    onChanged: (v) => setState(() => pizzaToppings[key] = v!),
                  )),
                ] else if (isBurger) ...[
                  _buildSectionHeader("ความสุกของเนื้อ (เลือก 1 อย่าง)", isRequired: true),
                  ...["Rare", "Medium Rare", "Medium", "Well Done"].map((val) => RadioListTile<String>(
                    title: Text(val),
                    value: val,
                    groupValue: selectedDoneness,
                    activeColor: Colors.green,
                    onChanged: (v) => setState(() => selectedDoneness = v!),
                  )),
                  _buildSectionHeader("เครื่องเคียงเพิ่มเติม", isRequired: false),
                  ...burgerToppings.keys.map((key) => CheckboxListTile(
                    title: Text(key),
                    value: burgerToppings[key],
                    activeColor: Colors.green,
                    onChanged: (v) => setState(() => burgerToppings[key] = v!),
                  )),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("ตัวเลือกเพิ่มเติม", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...availableOptions.map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: selectedOption,
                    activeColor: Colors.green,
                    onChanged: (val) => setState(() => selectedOption = val),
                  )),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
          _buildBottomOrderBar(finalUnitPrice),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isRequired = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[100],
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          if (isRequired) const Text(" *จำเป็น", style: TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBottomOrderBar(double unitPrice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          IconButton(onPressed: () => setState(() => quantity > 1 ? quantity-- : null), icon: const Icon(Icons.remove_circle_outline, color: Colors.green)),
          Text("$quantity", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => setState(() => quantity++), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B14F),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                String finalName = widget.food.title;
                if (widget.food.title.contains("Pizza")) {
                  String toppings = "";
                  pizzaToppings.forEach((k, v) { if(v) toppings += ", $k"; });
                  finalName += " ($selectedCrust$toppings)";
                } else if (widget.food.title.contains("Burger")) {
                  String toppings = "";
                  burgerToppings.forEach((k, v) { if(v) toppings += ", $k"; });
                  finalName += " ($selectedDoneness$toppings)";
                } else if (selectedOption != null) {
                  finalName += " ($selectedOption)";
                }

                cartItems.value.add(CartItem(
                  name: finalName,
                  price: unitPrice,
                  quantity: quantity,
                ));
                updateGlobalTotals();
                cartItems.notifyListeners();
                Navigator.pop(context);
              },
              child: Text("ใส่ตะกร้า ฿${(unitPrice * quantity).toInt()}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}