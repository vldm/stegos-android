import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/wallet/account/screen_account.dart';
import 'package:stegos_wallet/ui/wallet/wallet/screen_accounts.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

import '../themes.dart';

/// Main wallet screen with integrated TabBar.
///
class WalletScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  final walletIcon = 'assets/images/wallet.svg';

  final qrReaderIcon = 'assets/images/qr_reader.svg';

  final chatIcon = 'assets/images/chat.svg';

  final contactsIcon = 'assets/images/contacts.svg';

  final menu = SvgPicture.asset('assets/images/menu.svg');

  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  int selectedItem = 0;
  TabController _tabController;

  Widget _buildTabIcon(String assetName, bool selected) => SvgPicture.asset(assetName,
      color: selected ? StegosColors.primaryColor : StegosColors.primaryColorDark);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    _tabController.addListener(() {
      setState(() {
        selectedItem = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.walletTheme,
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            key: _drawerKey,
            appBar: AppBarWidget(
              centerTitle: false,
              leading: IconButton(
                icon: menu,
                onPressed: () => {_drawerKey.currentState.openDrawer()},
              ),
              title: const Text('Stegos Wallet'),
            ),
            drawer: Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: const Text('Stegos'),
                    decoration: BoxDecoration(
                      color: StegosColors.accentColor,
                    ),
                  ),
                  ListTile(
                    title: const Text('Develop'),
                    onTap: () { Navigator.pushNamed(context, Routes.devMenu);},
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              color: StegosColors.splashBackground,
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: _buildTabIcon(walletIcon, selectedItem == 0),
                    text: 'Wallet',
                  ),
                  Tab(
                    icon: _buildTabIcon(qrReaderIcon, selectedItem == 1),
                    text: 'QR Reader',
                  ),
                  Tab(
                    icon: _buildTabIcon(chatIcon, selectedItem == 2),
                    text: 'Chat',
                  ),
                  Tab(
                    icon: _buildTabIcon(contactsIcon, selectedItem == 3),
                    text: 'Contacts',
                  ),
                ],
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide.none,
                  insets: EdgeInsets.zero,
                ),
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                AccountsScreen(),
                Text('QR reader'),
                Text('Chat'),
                Text('Contacts'),
              ],
            ),
          ),
        ),
      );
}
