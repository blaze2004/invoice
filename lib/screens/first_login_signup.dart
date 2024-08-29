import 'package:flutter/material.dart';
import 'package:invoice/screens/signup.dart';

class FirstLoginSignup extends StatefulWidget {
  const FirstLoginSignup({super.key});
  @override
  State<FirstLoginSignup> createState() {
    return _FirstLoginSignup();
  }
}

class _FirstLoginSignup extends State<FirstLoginSignup> {
  @override
  Widget build(context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/ProfileLogo.png'),
                  ),
                ),
                const SizedBox(height: 40),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("or", style: TextStyle(color: Colors.white)),
                    ),
                    Expanded(child: Divider(color: Colors.white, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const Signup();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Create an Account'),
                ),
              ],
            ),
          ),
        ));
  }
}




//Maybe we can use Later
  //  // ElevatedButton.icon(
              //     onPressed: () {},
              //     icon: SvgPicture.asset(
              //       'Resources/google.svg',
              //       height: 30,
              //     ),
              //     label: const Text('Continue with Google'),
              //     style: ElevatedButton.styleFrom(
              //       textStyle: const TextStyle(fontWeight: FontWeight.bold),
              //       backgroundColor: Colors.white,
              //       foregroundColor: Colors.blueAccent,
              //       minimumSize: const Size(double.infinity, 50),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //   ),
              //   const SizedBox(height: 20),
              //   ElevatedButton.icon(
              //     onPressed: () {
              //       Navigator.push(context,
              //           MaterialPageRoute(builder: (context) {
              //         return const ListSocieties();
              //       }));
              //     },
              //     icon: Image.asset(
              //       'Resources/ProfileLogo.png',
              //       height: 40,
              //     ),
              //     label: const Text('Continue as a Guest'),
              //     style: ElevatedButton.styleFrom(
              //       textStyle: const TextStyle(fontWeight: FontWeight.bold),
              //       backgroundColor: Colors.white,
              //       foregroundColor: Colors.blueAccent,
              //       minimumSize: const Size(double.infinity, 50),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //   ),
