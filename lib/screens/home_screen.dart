import 'package:electrideuce/screens/garage.dart';
import 'package:electrideuce/screens/history.dart';
import 'package:electrideuce/screens/home.dart';
import 'package:electrideuce/screens/indexes.dart';
import 'package:electrideuce/screens/payment.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

void main() => runApp(home_screen());

class home_screen extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

//i have added garage file and initialized it in the screen list final screens=[garage(),......]
class _MyAppState extends State<home_screen> {
  int index = 0;
  final screens = [garage(), history(), payment(), indexes(), home()];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: screens[index],
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.blue.shade100,
            labelTextStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          child: NavigationBar(
              height: 60,
              backgroundColor: Colors.grey.shade300,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: index,
              animationDuration: const Duration(seconds: 3),
              onDestinationSelected: (index) =>
                  setState(() => this.index = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Ionicons.home_outline),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Ionicons.reader_outline),
                  selectedIcon: Icon(Ionicons.reader),
                  label: 'Indexes',
                ),
                NavigationDestination(
                  icon: Icon(Ionicons.wallet_outline),
                  selectedIcon: Icon(Ionicons.wallet),
                  label: 'Payment',
                ),
                NavigationDestination(
                  icon: Icon(Ionicons.list_outline),
                  selectedIcon: Icon(Ionicons.list),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Ionicons.information_circle_outline),
                  selectedIcon: Icon(Ionicons.information_circle),
                  label: 'Infor',
                ),
              ]),
        ),
      );
}
