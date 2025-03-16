import 'package:flutter/material.dart';
import 'package:mobilethree/mainpage.dart';
import 'package:mobilethree/postpage/creatpost.dart';
import 'package:mobilethree/postpage/fashionpage.dart';
import 'package:mobilethree/postpage/foodpage.dart';
import 'package:mobilethree/postpage/gamepage.dart';
import 'package:mobilethree/postpage/travelpage.dart';
import 'package:mobilethree/profile.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MusicPage> {
  int _selectedIndex = 0;

  void _navigateToPage(String page) {
    Widget nextPage;
    switch (page) {
      case 'All':
        nextPage = MainScreen();
        break;
      case 'Food':
        nextPage = FoodPage();
        break;
      case 'Travel':
        nextPage = TravelPage();
        break;
      case 'Music':
        nextPage = MusicPage();
        break;
      case 'Fashion':
        nextPage = FashionPage();
        break;
      case 'Game':
        nextPage = GamePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  void _goToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePostPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/imgs/logo.png',
              height: 60,
              width: 80,
            ),
            SizedBox(width: 8),
            Text('Zesty9',
                style: TextStyle(fontFamily: 'Gorditas', fontSize: 24, color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.purple[100],
      ),
      body: _selectedIndex == 0
          ? Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.amber[50],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['All', 'Food', 'Travel', 'Music', 'Fashion', 'Game']
                          .map((category) => GestureDetector(
                                onTap: () => _navigateToPage(category),
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color.fromARGB(255, 225, 190, 231)),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.purple[100],
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      "Welcome to Home Page",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          : ProfilePage(),

      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreatePost,
        backgroundColor: Colors.purple[100],
        child: Icon(Icons.edit, color: Colors.white), 
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.purple[400],
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.purple[100],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
