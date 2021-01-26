import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../common_widgets/edit_product_info_widget.dart';
import '../models/authentication_model.dart';

class VendorAdminLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<VendorAdminAuthenticationModel>(
      builder: (context, model, _) => Stack(
        children: [
          Scaffold(
            body: Container(
              width: size.width,
              height: size.height,
              color: Theme.of(context).backgroundColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Image.asset(
                      'assets/images/app_icon_transparent.png',
                      fit: BoxFit.fill,
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Fluxstore Admin',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    EditProductInfoWidget(
                      label: S.of(context).username,
                      fontSize: 12.0,
                      controller: model.usernameController,
                    ),
                    const SizedBox(height: 25),
                    EditProductInfoWidget(
                      label: S.of(context).password,
                      fontSize: 12.0,
                      controller: model.passwordController,
                      isObscure: true,
                    ),
//                    Row(
//                      children: [
//                        const Expanded(
//                          child: Text(
//                            'Forgot password?',
//                            style: TextStyle(
//                              fontSize: 12.0,
//                              color: Colors.blueAccent,
//                            ),
//                            textAlign: TextAlign.end,
//                          ),
//                        ),
//                      ],
//                    ),
                    const SizedBox(height: 50.0),
                    InkWell(
                      onTap: () => model.login(),
                      child: Container(
                        height: 44,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.blueAccent,
                        ),
                        child: model.state ==
                                VendorAdminAuthenticationModelState.loading
                            ? Center(
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  S.of(context).login.toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(S.of(context).orLoginWith),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (Platform.isIOS)
                          InkWell(
                            onTap: () => model.appleLogin(),
                            child: const Icon(
                              FontAwesomeIcons.apple,
                              size: 50.0,
                            ),
                          ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () => model.googleLogin(),
                          child: const Icon(
                            FontAwesomeIcons.google,
                            size: 40.0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () => model.facebookLogin(),
                          child: const Icon(
                            FontAwesomeIcons.facebook,
                            size: 40.0,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
          if (model.state == VendorAdminAuthenticationModelState.loading)
            Container(
              width: size.width,
              height: size.height,
              color: Colors.transparent,
            ),
        ],
      ),
    );
  }
}
