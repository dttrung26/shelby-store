import 'dart:convert';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/entities/user.dart';
import '../../../widgets/firebase/one_signal_wapper.dart';
import '../services/vendor_admin.dart';

enum VendorAdminAuthenticationModelState { loggedIn, notLogin, loading }

class VendorAdminAuthenticationModel extends ChangeNotifier {
  /// Service
  final _services = VendorAdminApi();

  /// State
  var state = VendorAdminAuthenticationModelState.notLogin;

  /// Your Other Variables Go Here
  User user;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  SharedPreferences _sharedPreferences;

  /// Constructor
  VendorAdminAuthenticationModel({this.user}) {
    if (user == null) {
      initLocalStorage().then((value) => getLocalUser());
    } else {
      _updateState(VendorAdminAuthenticationModelState.loggedIn);
    }
  }

  /// Update state
  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  /// Your Defined Functions Go Here

  void _clearControllers() {
    usernameController.clear();
    passwordController.clear();
  }

  Future<void> initLocalStorage() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> getLocalUser() async {
    var data = _sharedPreferences.getString('vendorUser');
    if (data != null) {
      var val = Utils.decodeUserData(data);
      user = User.fromLocalJson(jsonDecode(val));
      if (user == null) {
        _updateState(VendorAdminAuthenticationModelState.notLogin);
        return;
      }
      OneSignalWapper()..init();
      _updateState(VendorAdminAuthenticationModelState.loggedIn);
    } else {
      _updateState(VendorAdminAuthenticationModelState.notLogin);
    }
  }

  Future<void> saveLocalUser() async {
    var data = Utils.encodeData(jsonEncode(user));
    await _sharedPreferences.setString('vendorUser', data);
    OneSignalWapper()
      ..init()
      ..setExternalId(user.email);
    _clearControllers();
  }

  Future<void> login() async {
    _updateState(VendorAdminAuthenticationModelState.loading);
    user = await _services.login(
        username: usernameController.text, password: passwordController.text);
    if (user == null) {
      _updateState(VendorAdminAuthenticationModelState.notLogin);
      return;
    }
    await saveLocalUser();
    _updateState(VendorAdminAuthenticationModelState.loggedIn);
  }

  Future<void> logout() async {
    await _sharedPreferences.remove('vendorUser');
    await FacebookLogin().logOut();
    _updateState(VendorAdminAuthenticationModelState.notLogin);
  }

  Future<void> googleLogin() async {
    _updateState(VendorAdminAuthenticationModelState.loading);
    var _googleSignIn = GoogleSignIn(scopes: ['email']);
    var res = await _googleSignIn.signIn();

    if (res == null) {
      _updateState(VendorAdminAuthenticationModelState.notLogin);
    } else {
      var auth = await res.authentication;
      user = await _services.loginGoogle(token: auth.accessToken);
      if (user == null) {
        _updateState(VendorAdminAuthenticationModelState.notLogin);
        return;
      }
      await saveLocalUser();
      _updateState(VendorAdminAuthenticationModelState.loggedIn);
    }
  }

  Future<void> facebookLogin() async {
    _updateState(VendorAdminAuthenticationModelState.loading);
    final result = await FacebookLogin().logIn(['email', 'public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final accessToken = result.accessToken;
        user = await _services.loginFacebook(token: accessToken.token);
        if (user == null) {
          _updateState(VendorAdminAuthenticationModelState.notLogin);
          break;
        }
        await saveLocalUser();
        _updateState(VendorAdminAuthenticationModelState.loggedIn);
        break;
      default:
        _updateState(VendorAdminAuthenticationModelState.notLogin);
        break;
    }
  }

  Future<void> appleLogin() async {
    _updateState(VendorAdminAuthenticationModelState.loading);
    try {
      final result = await AppleSignIn.performRequests([
        const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      switch (result.status) {
        case AuthorizationStatus.authorized:
          {
            var email = '';
            var fullName = '';
            if (result.credential.email != null) {
              email = result.credential.email;
              fullName = result.credential.fullName.givenName +
                  ' ' +
                  result.credential.fullName.familyName;
            } else {
              var decodedToken = JwtDecoder.decode(
                  String.fromCharCodes(result.credential.identityToken));
              if (decodedToken != null &&
                  decodedToken['payload'] != null &&
                  decodedToken['payload']['email'] != null) {
                email = decodedToken['payload']['email'];
                fullName =
                    decodedToken['payload']['email'].toString().split('@')[0];
              } else {
                _updateState(VendorAdminAuthenticationModelState.notLogin);
              }
            }
            user = await _services.loginApple(email: email, fullName: fullName);
            if (user == null) {
              _updateState(VendorAdminAuthenticationModelState.notLogin);
              break;
            }
            await saveLocalUser();
            _updateState(VendorAdminAuthenticationModelState.loggedIn);
          }
          break;
        default:
          _updateState(VendorAdminAuthenticationModelState.notLogin);
          break;
      }
    } catch (err) {
      printLog(err);
      _updateState(VendorAdminAuthenticationModelState.notLogin);
    }
  }
}
