import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/user_model.dart';
import '../../../widgets/common/login_animation.dart';
import 'verify.dart';

class LoginSMS extends StatefulWidget {
  final bool fromCart;

  LoginSMS({this.fromCart = false});

  @override
  _LoginSMSState createState() => _LoginSMSState();
}

class _LoginSMSState extends State<LoginSMS> with TickerProviderStateMixin {
  AnimationController _loginButtonController;
  final TextEditingController _controller = TextEditingController(text: '');

  CountryCode countryCode;
  String phoneNumber;
  String _phone;
  bool isLoading = false;

  final StreamController<PhoneAuthCredential> _verifySuccessStream =
      StreamController<PhoneAuthCredential>.broadcast();

  @override
  void initState() {
    super.initState();
    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _phone = '';
    countryCode = CountryCode(
      code: LoginSMSConstants.countryCodeDefault,
      dialCode: LoginSMSConstants.dialCodeDefault,
      name: LoginSMSConstants.nameDefault,
    );
    _controller.addListener(() {
      if (_controller.text != _phone && _controller.text != '') {
        _phone = _controller.text;
        onPhoneNumberChange(
          _phone,
          '${countryCode.dialCode}$_phone',
          countryCode.code,
        );
      }
    });
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController.forward();
    } on TickerCanceled {
      printLog('[_playAnimation] error');
    }
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {
      printLog('[_stopAnimation] error');
    }
  }

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text('⚠️: $message'),
      duration: const Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    Scaffold.of(context)
      // ignore: deprecated_member_use
      ..removeCurrentSnackBar()
      // ignore: deprecated_member_use
      ..showSnackBar(snackBar);
  }

  void onPhoneNumberChange(
    String number,
    String internationalizedPhoneNumber,
    String isoCode,
  ) {
    if (internationalizedPhoneNumber.isNotEmpty) {
      phoneNumber = internationalizedPhoneNumber;
    } else {
      phoneNumber = null;
    }
  }

  Future<void> _loginSMS(context) async {
    if (phoneNumber == null) {
      Tools.showSnackBar(Scaffold.of(context), S.of(context).pleaseInput);
    } else {
      await _playAnimation();
      final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
        _stopAnimation();
      };

      final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
        _stopAnimation();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCode(
              fromCart: widget.fromCart,
              verId: verId,
              phoneNumber: phoneNumber,
              verifySuccessStream: _verifySuccessStream.stream,
            ),
          ),
        );
      };

      final verifiedSuccess = _verifySuccessStream.add;

      final PhoneVerificationFailed veriFailed =
          (FirebaseAuthException exception) {
        _stopAnimation();
        _failMessage(exception.message, context);
      };

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 120),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushNamed(RouteList.home);
            }
          },
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => Stack(
            children: [
              ListenableProvider.value(
                value: Provider.of<UserModel>(context),
                child: Consumer<UserModel>(
                  builder: (context, model, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 80.0),
                          Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 40.0,
                                    child: Image.asset(kLogo),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 120.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CountryCodePicker(
                                onChanged: (country) {
                                  setState(() {
                                    countryCode = country;
                                  });
                                },
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: countryCode.code,
                                //Get the country information relevant to the initial selection
                                onInit: (code) {
                                  countryCode = code;
                                },
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                      labelText: S.of(context).phone),
                                  keyboardType: TextInputType.phone,
                                  controller: _controller,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 60.0,
                          ),
                          StaggerAnimation(
                            titleButton: S.of(context).sendSMSCode,
                            buttonController: _loginButtonController.view,
                            onTap: () {
                              if (!isLoading) {
                                _loginSMS(context);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrimaryColorOverride extends StatelessWidget {
  const PrimaryColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(primaryColor: color),
    );
  }
}
