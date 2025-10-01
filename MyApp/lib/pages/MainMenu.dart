import 'package:flutter/material.dart';
import 'package:MobileApp/pages/Recommend.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/Dashboard.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCard(
                    "Welcome to NutraX | AI-Powered Nutrition Estimator",
                    "Upload a food image and get detailed nutritional insights instantly!"
                        " Our AI-powered system analyzes your food and provides essential nutrition information.",
                    Colors.orange,
                  ),
                  SizedBox(height: 12.0),
                  _buildCardButton(
                    context,
                    'Start',
                    Icons.add_a_photo_outlined,
                    FoodClassifierPage(),
                    Colors.green,
                  ),
                  SizedBox(height: 12.0),
                  _buildCardButton(
                    context,
                    'Logout',
                    Icons.exit_to_app,
                        () {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                    },
                    Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String description, Color color) {
    return Card(
      color: color.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton(
      BuildContext context,
      String title,
      IconData icon,
      dynamic page,
      Color backgroundColor) {
    return Card(
      color: backgroundColor.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: InkWell(
        onTap: () {
          if (page is Widget) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          } else {
            page();
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24.0, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                title,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}