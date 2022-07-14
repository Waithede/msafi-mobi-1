import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msafi_mobi/pages/launderMarts/profile/main.dart';
import 'package:msafi_mobi/pages/regular/processing/home.dart';
import 'package:msafi_mobi/pages/regular/processing/launder_view.dart';
import 'package:msafi_mobi/pages/regular/processing/settings.dart';
import 'package:msafi_mobi/themes/main.dart';
import 'package:provider/provider.dart';

import '../../../providers/merchant.provider.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({Key? key}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  List<Widget> routes = const [
    HomePageView(),
    LaunderView(),
    SettingsView(),
    AccountSettings(),
  ];
  Widget _currentPage = Container();
  dynamic merchantRoute;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentPage = routes[_count];
    });
    merchantRoute = context.read<MerchantRoute>();
    _count = merchantRoute.current;
  }

  _handleNavigation(index) {
    // update global  state
    merchantRoute.setCurrentPage(index);
    setState(() {
      // read from global state
      _count = merchantRoute.current;
      _currentPage = routes[_count];
      // set the current index to the index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _currentPage,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 50,
        enableFeedback: true,
        showUnselectedLabels: true,
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 13,
          color: Theme.of(context).colorScheme.secondary,
          height: 1.2,
          fontWeight: FontWeight.w600,
        ),
        unselectedItemColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Theme.of(context).primaryColor,
        showSelectedLabels: true,
        currentIndex: _count,
        selectedIconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        onTap: _handleNavigation,
        selectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 16,
          color: Theme.of(context).primaryColor,
          height: 1.8,
          fontWeight: FontWeight.w600,
        ),
        items: [
          BottomNavigationBarItem(
            label: 'Dashboard',
            icon: Icon(
              Icons.dashboard_outlined,
              color: Theme.of(context).colorScheme.secondary,
              size: 25,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Launders',
            icon: Icon(
              Icons.track_changes,
              color: Theme.of(context).colorScheme.secondary,
              size: 25,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Chats',
            icon: Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.secondary,
              size: 25,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            tooltip: "Profile",
            icon: Icon(
              Icons.person_outline_outlined,
              color: Theme.of(context).colorScheme.secondary,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}
