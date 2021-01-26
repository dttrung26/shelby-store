part of '../config.dart';

/// Everything Config about the Payment

/// TODO 3.3 - Payments Setting 💳
/// config for payment features
const kPaymentConfig = {
  'DefaultCountryISOCode': 'VN',

  'DefaultStateISOCode': 'SG',

  /// Enable the Shipping option from Checkout, support for the Digital Download
  'EnableShipping': true,

  /// Enable the address shipping.
  /// Set false if use for the app like Download Digial Asset which is not required the shipping feature.
  'EnableAddress': true,

  /// Allow customers to add note when order
  'EnableCustomerNote': true,

  /// Allow customers to add address location link to order note
  'EnableAddressLocationNote': false,

  /// Enable the product review option
  'EnableReview': true,

  /// enable the google map picker from Billing Address
  'allowSearchingAddress': true,
  'GuestCheckout': true,

  /// Enable Payment option
  'EnableOnePageCheckout': false,
  'NativeOnePageCheckout': false,

  /// This config is same with checkout page slug in the website
  'CheckoutPageSlug': {'en': 'checkout'},

  /// Enable Credit card payment (only available for Fluxstore Shopipfy)
  'EnableCreditCard': false,

  /// Enable update order status to processing after checkout by COD on woo commerce
  'UpdateOrderStatus': false,

  /// Show Refund and Cancel button on Order Detail
  'EnableRefundCancel': false,
};

const Payments = {
  'paypal': 'assets/icons/payment/paypal.png',
  'stripe': 'assets/icons/payment/stripe.png',
  'razorpay': 'assets/icons/payment/razorpay.png',
  'tap': 'assets/icons/payment/tap.png',
};

/// this Stripe payment only available for Extended Account
/// that is used for Commercial purpose
/// paymentMethodId: should meet the payment method from website
const kStripeConfig = {
  'serverEndpoint': 'https://stripe-server.vercel.app',
  'publishableKey': 'pk_test_MOl5vYzj1GiFnRsqpAIHxZJl',
  'enabled': true,
  'paymentMethodId': 'stripe',
  'returnUrl': 'fluxstore://inspireui.com',

  /// Enable this automatically captures funds when the customer authorizes the payment.
  /// Disable will Place a hold on the funds when the customer authorizes the payment,
  /// but don’t capture the funds until later. (Not all payment methods support this.)
  /// https://stripe.com/docs/payments/capture-later
  /// Default: false
  'enableManualCapture': false,
};

const PaypalConfig = {
  'clientId':
      'ASlpjFreiGp3gggRKo6YzXMyGM6-NwndBAQ707k6z3-WkSSMTPDfEFmNmky6dBX00lik8wKdToWiJj5w',
  'secret':
      'ECbFREri7NFj64FI_9WzS6A0Az2DqNLrVokBo0ZBu4enHZKMKOvX45v9Y1NBPKFr6QJv2KaSp5vk5A1G',
  'production': false,
  'paymentMethodId': 'paypal',
  'enabled': true
};

const RazorpayConfig = {
  'keyId': 'rzp_test_SDo2WKBNQXDk5Y',
  'keySecret': 'RrgfT3oxbJdaeHSzvuzaJRZf',
  'paymentMethodId': 'razorpay',
  'enabled': true
};

const TapConfig = {
  'SecretKey': 'sk_test_XKokBfNWv6FIYuTMg5sLPjhJ',
  'paymentMethodId': 'tap',
  'enabled': true
};

const MercadoPagoConfig = {
  'accessToken':
      'TEST-5726912977510261-102413-65873095dc5b0a877969b7f6ffcceee4-613803978',
  'production': false,
  'paymentMethodId': 'woo-mercado-pago-basic',
  'enabled': true
};

/// config for after shipping
const afterShip = {
  'api': 'e2e9bae8-ee39-46a9-a084-781d0139274f',
  'tracking_url': 'https://fluxstore.aftership.com'
};

/// TODO 3.4 - Shipping Address - Default Country 🛳
/// Limit the country list from Billing Address
/// []: default show all country
const List DefaultCountry = [];

//const List DefaultCountry = [
//  {
//    "name": "Vietnam",
//    "iosCode": "VN",
//    "icon": "https://cdn.britannica.com/41/4041-004-A06CBD63/Flag-Vietnam.jpg"
//  },
//  {
//    "name": "India",
//    "iosCode": "IN",
//    "icon":
//        "https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/1200px-Flag_of_India.svg.png"
//  },
//  {"name": "Austria", "iosCode": "AT", "icon": ""},
//];
