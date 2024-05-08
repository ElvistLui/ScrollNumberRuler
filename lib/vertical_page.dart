import 'package:flutter/material.dart';
import 'package:flutter_app/vertical_numberpicker.dart';

class VerticalPage extends StatefulWidget {
  VerticalPage({Key? key}) : super(key: key);

  @override
  _VerticalPageState createState() => _VerticalPageState();
}

class _VerticalPageState extends State<VerticalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("竖向滚动"),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              color: Colors.grey.withOpacity(0.5),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: VerticalNumberPicker(
                initialValue: 20,
                minValue: 2,
                maxValue: 24,
                step: 1,
                widgetWidth: 200,
                widgetHeight: MediaQuery.of(context).size.height.round() - 200,
                subGridCountPerGrid: 2,
                subGridHeight: 27,
                onSelectedChanged: (value) {
                  print(value);
                },
                scaleTransformer: (value) {
                  return "${value ~/ 2}月";
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 12,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.grey.withOpacity(index.toDouble() / 120),
                    height: 100,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
