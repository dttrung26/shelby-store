class NotificationVendorAdmin {
  String iD;
  String message;
  String messageType;
  String created;
  String orderId;

  NotificationVendorAdmin(
      {this.iD, this.message, this.messageType, this.created});

  NotificationVendorAdmin.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    message = json['message'];

    try {
      var exp = RegExp(r'\B#\d\d+');
      orderId = exp.firstMatch(message).group(0);
      orderId = orderId.replaceAll('#', '');
    } catch (e) {
      orderId = '';
    }
    messageType = json['message_type'];
    messageType = messageType.replaceAll('_', ' ');
    messageType = messageType.replaceAll('-', ' ');
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ID'] = iD;
    data['message'] = message;
    data['message_type'] = messageType;
    data['created'] = created;
    return data;
  }
}
