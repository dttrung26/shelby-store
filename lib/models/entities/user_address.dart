class Shipping {
  String firstName;
  String lastName;
  String company;
  String address1;
  String address2;
  String city;
  String postCode;
  String country;
  String state;

  Shipping.fromJson(Map<String, dynamic> json) {
    try {
      firstName = json['first_name'];
      lastName = json['last_name'];
      company = json['company'];
      address1 = json['address_1'];
      address2 = json['address_2'];
      city = json['city'];
      postCode = json['postcode'];
      country = json['country'];
      state = json['state'];
    } catch (_) {}
  }
}

class Billing {
  String firstName;
  String lastName;
  String company;
  String address1;
  String address2;
  String city;
  String postCode;
  String country;
  String state;
  String email;
  String phone;

  Billing.fromJson(Map<String, dynamic> json) {
    try {
      firstName = json['first_name'];
      lastName = json['last_name'];
      company = json['company'];
      address1 = json['address_1'];
      address2 = json['address_2'];
      city = json['city'];
      postCode = json['postcode'];
      country = json['country'];
      state = json['state'];
      email = json['email'];
      phone = json['phone'];
    } catch (_) {}
  }
}
