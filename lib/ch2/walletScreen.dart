import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double myBalance = 5000.0;
  bool showBalance = true;

  // ข้อมูลโปรโมชัน (จัดเก็บในรูปแบบ List ของ Map เพื่อนำไปใช้กับ ListView.builder ในแบบที่ 2)
  final List<Map<String, dynamic>> promotions = [
    {
      'title': 'ลดทันที 50 บาท',
      'desc': 'เมื่อจ่ายบิลค่าน้ำไฟครั้งแรกของเดือน',
      'color': Colors.redAccent,
    },
    {
      'title': 'รับพอยท์ x2',
      'desc': 'เติมเงินเกมโปรดผ่านแอปวันนี้ รับคะแนนสองเท่า',
      'color': Colors.blueAccent,
    },
    {
      'title': 'ชวนเพื่อนรับ 100',
      'desc': 'เมื่อเพื่อนสมัครใช้งานและยืนยันตัวตนสำเร็จ',
      'color': Colors.green, // สีเขียวสวยๆ
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // ปรับพื้นหลังแอปให้ดูสบายตาขึ้น
      appBar: AppBar(
        title: const Text(
          'My Wallet',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ [แบบที่ 1 & 3]: เรียกใช้ Custom Widget ยอดเงินแบบ Modern ไล่เฉดสี 
            BalanceCard(
              balance: myBalance,
              showBalance: showBalance,
              onToggleVisibility: () {
                setState(() {
                  showBalance = !showBalance;
                });
              },
            ),

            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 12),
              child: Text(
                'โปรโมชันพิเศษสำหรับคุณ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // ✨ [แบบที่ 2]: ปรับโปรโมชันเป็นแบบสไลด์แนวนอนด้วย ListView.builder
            // ✨ ปรับโค้ดในส่วน ListView.builder ภายในเมธอด build ของ WalletScreen เป็นแบบนี้ได้เลยครับ
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                  final promo = promotions[index];
                  
                  // 💡 นำ GestureDetector มาครอบ เพื่อให้การ์ดโปรโมชันแต่ละใบกดคลิกได้
                  return GestureDetector(
                    onTap: () {
                      // เมื่อกดคลิก ให้เด้งหน้าต่างแจ้งเตือนขึ้นมาแสดงข้อมูลของโปรโมชันใบนั้น
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              promo['title'], // แสดงชื่อโปรโมชันที่กด
                              style: TextStyle(color: promo['color'], fontWeight: FontWeight.bold),
                            ),
                            content: Text(promo['desc']), // แสดงรายละเอียดโปรโมชัน
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('ตกลง'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: SizedBox(
                      width: 300,
                      child: PromoCard(
                        title: promo['title'],
                        desc: promo['desc'],
                        color: promo['color'],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _showExpenseDialog,
        child: const Icon(Icons.remove, color: Colors.white, size: 28),
      ),
    );
  }

  // ฟังก์ชันแสดง Dialog หักเงินเดิม (คงไว้ตามตรรกะเดิมของคุณ)
  void _showExpenseDialog() {
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Expense'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter your expense:'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (priceController.text.isNotEmpty) {
                  setState(() {
                    myBalance = myBalance - double.parse(priceController.text);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

// ==========================================
// 💡 [แบบที่ 1 & 3] CUSTOM BALANCE CARD (StatelessWidget)
// ย้าย UI ออกมาด้านนอกเพื่อความ Clean และแต่งสไตล์ Glassmorphism / Gradient
// ==========================================
class BalanceCard extends StatelessWidget {
  final double balance;
  final bool showBalance;
  final VoidCallback onToggleVisibility; // ฟังก์ชัน Callback สำหรับส่งค่ากลับไปให้ตัวแม่สั่ง setState

  const BalanceCard({
    super.key,
    required this.balance,
    required this.showBalance,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // ปรับดีไซน์ไล่เฉดสีน้ำเงิน-ม่วงแบบพรีเมียม
        gradient: const LinearGradient(
          colors: [Color(0xFF3A1C71), Color(0xFFD76D77)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24), // ปรับขอบมนขึ้น
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL BALANCE',
                style: TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: Icon(
                  showBalance ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: onToggleVisibility, // เรียกใช้งานฟังก์ชันที่แม่ส่งมา
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            showBalance ? '฿${balance.toStringAsFixed(2)}' : '฿ • • • • • •',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32, // ปรับขนาดตัวเลขให้เด่นชัดขึ้น
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🟣 PROMO CARD WIDGET (StatelessWidget)
// ==========================================
class PromoCard extends StatelessWidget {
  final String title;
  final String desc;
  final Color color;

  const PromoCard({
    super.key,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Center( // ใช้ Center เพื่อจัดตำแหน่งภายในกรณีที่แสดงผลในแนวนอน
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            desc,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis, // ป้องกันตัวหนังสือล้นกรอบแนวตั้ง
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}