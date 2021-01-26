import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).agreeWithPrivacy,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            S.of(context).privacyTerms,
            style: const TextStyle(fontSize: 15.0, height: 1.4),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
