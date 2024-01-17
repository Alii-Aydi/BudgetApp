import 'package:budgettn/services/auth/log_out.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerTemp extends StatelessWidget {
  const DrawerTemp({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userPhotoUrl;
    if (user != null) {
      userPhotoUrl = user.photoURL;
    }
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://img.freepik.com/free-photo/billie-dollar-money-background_1150-749.jpg?w=740&t=st=1705346756~exp=1705347356~hmac=350e06d2fed2acd6ff9fc09dc601c1bfb5fcf244e26387bb479168df82e1196b'), // Replace with your image asset path
                fit: BoxFit.cover,
              ),
            ),
            child: userPhotoUrl != null
                ? CircleAvatar(
                    child: Container(
                      child: ClipOval(
                        child: Image.network(
                          userPhotoUrl,
                          fit: BoxFit.cover,
                          width: 140.0,
                          height: 140.0,
                        ),
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 50.0,
                    child: Icon(Icons.account_circle),
                  ),
          ),
          user != null? ListTile(
            title: Text('Budget'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/");
            },
          ) : SizedBox.shrink(),
          user != null? ListTile(
            title: Text('Dashbord'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/dash");
            },
          ) :  SizedBox.shrink(),
          ListTile(
            title: Text('About us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/about");
            },
          ),
          user != null? LogOut() : ListTile(
            title: Text('Sign In'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/");
            },
          ),
        ],
      ),
    );
  }
}
