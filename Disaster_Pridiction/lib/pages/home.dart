import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Stack(
          children: [
            Positioned(
              top: 60, // Adjust the top and left values to control the position
              left: 17.5,
              child: Container(
                width: 350,
                height: 370,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(3, 3),
                          blurRadius: 2)
                    ]),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 300,
                      left: 30,
                      right: 20,
                      child: Text(
                        'Mumbai:  Light Rain',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      right: -80,
                      child: SizedBox(
                        width: 500, // Adjust the width here
                        height: 500, // Adjust the height here
                        child: Lottie.asset(
                          'assets/Lottie/rain.json', // Path to your Lottie animation file
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top:
                  440, // Adjust the top and left values to control the position
              left: 17.5,
              child: Container(
                width: 350,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(3, 3),
                          blurRadius: 2)
                    ]),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 30,
                      left: 30,
                      right: 20,
                      child: Text(
                        'Temperature: 27 C',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 280,
                      child: SizedBox(
                        width: 50, // Adjust the width here
                        height: 50, // Adjust the height here
                        child: Lottie.asset(
                          'assets/Lottie/temp.json', // Path to your Lottie animation file
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top:
                  530, // Adjust the top and left values to control the position
              left: 17.5,
              child: Container(
                width: 350,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(3, 3),
                          blurRadius: 2)
                    ]),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 30,
                      left: 30,
                      right: 20,
                      child: Text(
                        'Wind: 11 km/h',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 280,
                      child: SizedBox(
                        width: 50, // Adjust the width here
                        height: 50, // Adjust the height here
                        child: Lottie.asset(
                          'assets/Lottie/wind.json', // Path to your Lottie animation file
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top:
                  620, // Adjust the top and left values to control the position
              left: 17.5,
              child: Container(
                width: 350,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(3, 3),
                          blurRadius: 2)
                    ]),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 30,
                      left: 30,
                      right: 20,
                      child: Text(
                        'Humidity: 88%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 280,
                      child: SizedBox(
                        width: 50, // Adjust the width here
                        height: 50, // Adjust the height here
                        child: Lottie.asset(
                          'assets/Lottie/humidity.json', // Path to your Lottie animation file
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
