import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, PointModel, User, UserModel;
import '../../widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // final _auth = firebase_auth.FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();

  String firstName, lastName, emailAddress, phoneNumber, password;
  bool isVendor = false;
  bool isChecked = false;

  final bool showPhoneNumberWhenRegister =
      kLoginSetting['showPhoneNumberWhenRegister'] ?? false;
  final bool requirePhoneNumberWhenRegister =
      kLoginSetting['requirePhoneNumberWhenRegister'] ?? false;

  final firstNameNode = FocusNode();
  final lastNameNode = FocusNode();
  final phoneNumberNode = FocusNode();
  final emailNode = FocusNode();
  final passwordNode = FocusNode();

  void _welcomeDiaLog(User user) {
    Provider.of<CartModel>(context, listen: false).setUser(user);
    Provider.of<PointModel>(context, listen: false).getMyPoint(user.cookie);
    var email = user.email;
    _snackBar(S.of(context).welcome + ' $email!');
    // if (kIsWeb) {
    //   Navigator.of(context).pushReplacementNamed('/home-screen');
    // } else {
    //   Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
    // }
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed(RouteList.dashboard);
  }

  @override
  void dispose() {
    _emailController.dispose();
    firstNameNode.dispose();
    lastNameNode.dispose();
    emailNode.dispose();
    passwordNode.dispose();
    phoneNumberNode.dispose();
    super.dispose();
  }

  void _snackBar(String text) {
    if (mounted) {
      final snackBar = SnackBar(
        content: Text('$text'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: S.of(context).close,
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      // ignore: deprecated_member_use
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  Future<void> _submitRegister({
    String firstName,
    String lastName,
    String phoneNumber,
    String emailAddress,
    String password,
    bool isVendor,
  }) {
    if (firstName == null ||
        lastName == null ||
        emailAddress == null ||
        password == null ||
        (showPhoneNumberWhenRegister &&
            requirePhoneNumberWhenRegister &&
            phoneNumber == null)) {
      _snackBar(S.of(context).pleaseInputFillAllFields);
    } else if (isChecked == false) {
      _snackBar(S.of(context).pleaseAgreeTerms);
    } else {
      Provider.of<UserModel>(context, listen: false).createUser(
        username: emailAddress,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        success: _welcomeDiaLog,
        fail: _snackBar,
        isVendor: isVendor,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (kLoginSetting['IsRequiredLogin']) {
              Navigator.of(context).pushNamed(RouteList.login);
            } else {
              Navigator.of(context).pushNamed(RouteList.dashboard);
            }
          },
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Utils.hideKeyboard(context),
          child: ListenableProvider.value(
            value: Provider.of<UserModel>(context),
            child: Consumer<UserModel>(
              builder: (context, value, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 10.0),
                        Center(
                          child: Image.asset(
                            kLogo,
                            width: MediaQuery.of(context).size.width / 2,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        CustomTextField(
                          onChanged: (value) => firstName = value,
                          textCapitalization: TextCapitalization.words,
                          nextNode: lastNameNode,
                          showCancelIcon: true,
                          decoration: InputDecoration(
                            labelText: S.of(context).firstName,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        CustomTextField(
                          focusNode: lastNameNode,
                          nextNode: showPhoneNumberWhenRegister
                              ? phoneNumberNode
                              : emailNode,
                          showCancelIcon: true,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) => lastName = value,
                          decoration: InputDecoration(
                            labelText: S.of(context).lastName,
                          ),
                        ),
                        if (showPhoneNumberWhenRegister)
                          const SizedBox(height: 20.0),
                        if (showPhoneNumberWhenRegister)
                          CustomTextField(
                            focusNode: phoneNumberNode,
                            nextNode: emailNode,
                            showCancelIcon: true,
                            onChanged: (value) => phoneNumber = value,
                            decoration: InputDecoration(
                              labelText: S.of(context).phone,
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        const SizedBox(height: 20.0),
                        CustomTextField(
                          focusNode: emailNode,
                          nextNode: passwordNode,
                          controller: _emailController,
                          onChanged: (value) => emailAddress = value,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: S.of(context).enterYourEmail),
                        ),
                        const SizedBox(height: 20.0),
                        CustomTextField(
                          focusNode: passwordNode,
                          showEyeIcon: true,
                          obscureText: true,
                          onChanged: (value) => password = value,
                          decoration: InputDecoration(
                            labelText: S.of(context).enterYourPassword,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        if (kVendorConfig['VendorRegister'] == true &&
                            Provider.of<AppModel>(context, listen: false)
                                    .vendorType ==
                                VendorType.multi)
                          Row(
                            children: <Widget>[
                              Checkbox(
                                value: isVendor,
                                activeColor: Theme.of(context).primaryColor,
                                checkColor: Colors.white,
                                onChanged: (value) {
                                  setState(() {
                                    isVendor = value;
                                  });
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  isVendor = !isVendor;
                                  setState(() {});
                                },
                                child: Text(
                                  S.of(context).registerAsVendor,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: isChecked,
                              activeColor: Theme.of(context).primaryColor,
                              checkColor: Colors.white,
                              onChanged: (value) {
                                isChecked = !isChecked;
                                setState(() {});
                              },
                            ),
                            InkWell(
                              onTap: () {
                                isChecked = !isChecked;
                                setState(() {});
                              },
                              child: Text(
                                S.of(context).iwantToCreateAccount,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: isChecked,
                              activeColor: Theme.of(context).primaryColor,
                              checkColor: Colors.white,
                              onChanged: (value) {
                                isChecked = !isChecked;
                                setState(() {});
                              },
                            ),
                            InkWell(
                              onTap: () {
                                isChecked = !isChecked;
                                setState(() {});
                              },
                              child: Text(
                                S.of(context).iAgree,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PrivacyScreen()),
                                );
                              },
                              child: Text(
                                S.of(context).agreeWithPrivacy,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.0,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Material(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                            elevation: 0,
                            child: MaterialButton(
                              onPressed: value.loading == true
                                  ? null
                                  : () async {
                                      await _submitRegister(
                                        firstName: firstName,
                                        lastName: lastName,
                                        phoneNumber: phoneNumber,
                                        emailAddress: emailAddress,
                                        password: password,
                                        isVendor: isVendor,
                                      );
                                    },
                              minWidth: 200.0,
                              elevation: 0.0,
                              height: 42.0,
                              child: Text(
                                value.loading == true
                                    ? S.of(context).loading
                                    : S.of(context).createAnAccount,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                S.of(context).or + ' ',
                                style: const TextStyle(color: Colors.black45),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  S.of(context).loginToYourAccount,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
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
            style: const TextStyle(fontSize: 16.0, height: 1.4),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
