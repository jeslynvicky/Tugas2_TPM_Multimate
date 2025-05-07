import 'package:flutter/material.dart';
import 'package:project2/data/phone_data.dart';
import 'package:project2/pages/detail_page.dart';

class WebsiteRecommendationPage extends StatefulWidget {
  const WebsiteRecommendationPage({super.key});

  @override
  State<WebsiteRecommendationPage> createState() =>
      _WebsiteRecommendationPageState();
}

class _WebsiteRecommendationPageState extends State<WebsiteRecommendationPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // supaya gradasi kelihatan
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Phone Recommendation",
            style: TextStyle(color: Colors.white), // agar kontras di gradasi
          ),
          centerTitle: true,
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) => _phonesData(context, index),
            itemCount: phones.length,
          ),
        ),
      ),
    );
  }

  Widget _phonesData(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DetailPage(index: index)));
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 1),
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.network(phones[index].imageUrl),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phones[index].model,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(
                    phones[index].brand,
                    style: TextStyle(color: const Color.fromARGB(255, 208, 190, 190)),
                  ),
                  Text(
                    "\$ ${phones[index].price[0]}",
                    style: TextStyle(color: const Color.fromARGB(255, 24, 240, 31)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}