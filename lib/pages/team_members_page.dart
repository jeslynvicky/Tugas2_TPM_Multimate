import 'package:flutter/material.dart';

class MemberListScreen extends StatefulWidget {
  @override
  _MemberListScreenState createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final PageController _pageController = PageController();
  final List<Map<String, String>> members = [
    {
      'instagram': 'mafahaq',
      'name': 'Muhammad Almas Farros D',
      'nim': '123220133',
      'image': 'assets/images/farros.jpg'
    },
    {
      'instagram': 'jeslyn.vh',
      'name': 'Jeslyn Vicky Hanjaya',
      'nim': '123220150',
      'image': 'assets/images/jeslyn.jpg'
    },
    {
      'instagram': 'restirama_',
      'name': 'Resti Ramadhani',
      'nim': '123220147',
      'image': 'assets/images/resti.jpg'
    },
  ];
  int currentIndex = 0;

  void nextPage() {
    if (currentIndex < members.length - 1) {
      setState(() {
        currentIndex++;
        _pageController.animateToPage(currentIndex,
            duration: Duration(milliseconds: 500), curve: Curves.easeOutCubic);
      });
    }
  }

  void prevPage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _pageController.animateToPage(currentIndex,
            duration: Duration(milliseconds: 500), curve: Curves.easeOutCubic);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Multi App',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF6A11CB),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFE6E6FA)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Title at the top
              Positioned(
                top: 30,
                child: Text(
                  'Our Team',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A11CB),
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),

              // Page indicator - memindahkan lebih ke bawah
              Positioned(
                bottom: 30, // Memindahkan indikator lebih ke bawah
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    members.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      height: 10,
                      width: currentIndex == index ? 30 : 10,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),

              // Member cards
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Container(
                        width: 320,
                        height: 500, // Mengurangi sedikit tinggi kartu
                        margin:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 60),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            // Profile image with border
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  members[index]['image']!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 25),
                            // Member details with better typography
                            Text(
                              members[index]['name']!,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2980),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 5),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A2980).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                members[index]['nim']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A2980),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            // Instagram ID dengan desain yang lebih sesuai
                            Container(
                              width: 260,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF833AB4), // Instagram gradient
                                    Color(0xFFF56040),
                                    Color(0xFFFF0080),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.white), // Icon Instagram
                                  SizedBox(width: 8),
                                  Text(
                                    "@${members[index]['instagram']!}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Navigation buttons dengan warna yang lebih kontras
              Positioned(
                left: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Membuat tombol lebih terlihat
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF6A11CB)),
                    onPressed: prevPage,
                    iconSize: 24,
                  ),
                ),
              ),
              Positioned(
                right: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Membuat tombol lebih terlihat
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Color(0xFF6A11CB)),
                    onPressed: nextPage,
                    iconSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}