import 'package:flutter/material.dart';

class GetNetworkImage extends StatefulWidget {
  @override
  _StateGetNetworkImage createState() => _StateGetNetworkImage();
}

class _StateGetNetworkImage extends State<GetNetworkImage> {
  TextEditingController imageNetwork;

  @override
  void initState() {
    imageNetwork = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Network',
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: <Widget>[
            TextField(
              controller: imageNetwork,
              decoration:
                  const InputDecoration(hintText: 'Past your image url'),
            ),
            Container(
              color: Theme.of(context).backgroundColor,
              constraints: const BoxConstraints(minHeight: 300),
              child: Image.network(imageNetwork.text),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context, imageNetwork.text);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: const Text(
                  'Upload',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
