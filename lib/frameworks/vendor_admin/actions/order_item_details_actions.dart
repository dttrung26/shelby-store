part of '../screens/order_item_details_screen.dart';

extension OrderItemDetailsAction on _VendorAdminOrderItemDetailsScreenState {
  Future<void> _getOrderNotes() async {
    orderNotes = await _services.getVendorAdminOrderNotes(
        page: page, perPage: _perPage, orderId: widget.order.id);
    // ignore: invalid_use_of_protected_member
    setState(() {});
  }

//  Future<void> _loadMoreOrderNotes() async {
//    page++;
//    await _services.getVendorAdminOrderNotes(
//        page: page, perPage: _perPage, orderId: widget.order.id);
//    // ignore: invalid_use_of_protected_member
//    setState(() {});
//  }

  String formatTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year}';
  }

  Color _buildStatusColor(String status) {
    switch (status) {
      case 'pending':
        {
          return Colors.yellow;
        }
      case 'processing':
        {
          return Colors.orange;
        }
      case 'completed':
        {
          return Colors.green;
        }
      case 'refunded':
        {
          return Colors.red;
        }
      default:
        return Colors.yellow;
    }
  }

  void _cancelEdit() {
    // ignore: invalid_use_of_protected_member
    setState(() {
      _dropdownStatusValue = widget.order.status.toLowerCase();
      _noteController.text = widget.order.customerNote;
    });
  }

  Widget _buildStatus(String status) {
    switch (status) {
      case 'pending':
        return Text(S.of(context).orderStatusPending);
      case 'refunded':
        return Text(S.of(context).orderStatusRefunded);
      case 'completed':
        return Text(S.of(context).orderStatusCompleted);
      case 'processing':
        return Text(S.of(context).orderStatusProcessing);
      default:
        return const Text('');
    }
  }

  void _updateOrder() {
    widget.onCallBack(_dropdownStatusValue, _noteController.text);
    Navigator.of(context).pop();
  }

  /// For IOS
  void _showBottomSheetOptions() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (subContext) => CupertinoActionSheet(
              actions: List.generate(
                statuses.length,
                (index) => CupertinoActionSheetAction(
                    onPressed: () {
                      // ignore: invalid_use_of_protected_member
                      setState(() => _dropdownStatusValue = statuses[index]);
                      Navigator.of(subContext).pop();
                    },
                    child: _buildStatus(statuses[index])),
              ),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.of(subContext).pop(),
                child: Text(S.of(context).cancel),
                isDefaultAction: true,
              ),
            ));
  }

  Widget _buildListStatuses() {
    final isIOS = Platform.isIOS;

    if (!isIOS) {
      return DropdownButton<String>(
        value: _dropdownStatusValue,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (String newValue) {
          // ignore: invalid_use_of_protected_member
          setState(() => _dropdownStatusValue = newValue);
        },
        items: statuses.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
    }

    return InkWell(
      onTap: _showBottomSheetOptions,
      child: Container(
        padding: const EdgeInsets.only(left: 15.0, top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Text(
              _dropdownStatusValue,
              style: TextStyle(fontSize: fontSize),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
