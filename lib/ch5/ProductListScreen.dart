import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // สร้างตัวแปรเก็บ Future เพื่อป้องกันไม่ให้ FutureBuilder รันใหม่ทุกครั้งที่มีการกดรีเฟรชหน้าจอ
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts();
  }

  // 1. fetch ข้อมูลจาก API (Asynchronous)
  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/products'),
    );

    if (response.statusCode == 200) {
      // ok, convert Text to Dart's List
      return jsonDecode(response.body);
    } else {
      throw Exception('Can not load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platzi Store Products'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      // 2. ใช้ FutureBuilder โดยส่งตัวแปร _productsFuture เข้าไป
      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          // state1: loaddata(Async กำลังทำงาน)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // state2: error (เช่น เน็ตหลุด หรือ API ล่ม)
          else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          // state3: success
          else if (snapshot.hasData) {
            final products = snapshot.data!;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];

                // ดึงรูปภาพตัวแรกจากลิสต์ (Platzi ส่งมาเป็น List ของ string รูปภาพ)
                // และครอบด้วยลองเช็กเผื่อกรณีไม่มีรูปภาพส่งมา
                String imageUrl = "https://placeholder.co/150"; 
                if (item['images'] != null && item['images'].isNotEmpty) {
                  imageUrl = item['images'][0];
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8), // มนขอบรูปภาพให้สวยงาม
                      child: Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        // ใส่กรณีที่รูปภาพโหลดไม่ผ่าน จะได้ไม่เกิด Error หน้าจอแดง
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      item['title'] ?? 'No Title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item['price']} USD',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // ...navigation ไปหน้ารายละเอียดสินค้าในอนาคต
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: Text('no data'));
        },
      ),
    );
  }
}