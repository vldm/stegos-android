import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/certificate/screen_certificate.dart';
import 'package:stegos_wallet/ui/themes.dart';

class TransactionsList extends StatefulWidget {
  TransactionsList(this.account);

  final AccountStore account;

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> with TickerProviderStateMixin {
  AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(duration: const Duration(seconds: 20), vsync: this);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.AccountTheme,
        child: Container(
          alignment: Alignment.topCenter,
          child: Observer(
            builder: (context) {
              return widget.account.txList.isEmpty
                  ? const Text(
                      'No transactions yet',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    )
                  : ListView(
                      children: widget.account.txList
                          .map((tx) => _buildTransactionRow(widget.account, tx))
                          .toList(),
                    );
            },
          ),
        ),
      );

  Widget _buildTransactionRow(AccountStore account, TxStore transaction) => Padding(
        padding: const EdgeInsets.only(left: 20, right: 10, top: 25, bottom: 25),
        child: Container(
            height: 39,
            child: Stack(
              children: <Widget>[
                Container(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: transaction.finished
                                ? Icon(Icons.check, size: 16, color: const Color(0xff32ff6b))
                                : RotationTransition(
                                    turns:
                                        Tween(begin: 0.0, end: 2 * pi).animate(_rotationController),
                                    child: Icon(Icons.autorenew,
                                        size: 16, color: StegosColors.accentColor))),
                        Text(
                          transaction.amount > 0 ? 'Received' : 'Sent',
                          style: const TextStyle(fontSize: 16, color: StegosColors.white),
                        )
                      ],
                    )),
                Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      transaction.created,
                      style: const TextStyle(fontSize: 12, color: StegosColors.white),
                    )),
                Container(
                  alignment: Alignment.topRight,
                  margin: const EdgeInsets.only(right: 54),
                  child: Text(
                    '${transaction.amount.toString()} STG',
                    style: TextStyle(
                        fontSize: 16,
                        color: transaction.amount > 0 ? const Color(0xff32ff6b) : Colors.white),
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  child: transaction.certificateURL != null
                      ? InkResponse(
                          onTap: _openCertificate,
                          child: SvgPicture.asset(
                            'assets/images/certificate.svg',
                            width: 24,
                            height: 24,
                          ),
                        )
                      : null,
                )
              ],
            )),
      );

  void _openCertificate() {
    StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => CertificateScreen(),
      fullscreenDialog: true,
    ));
  }
}