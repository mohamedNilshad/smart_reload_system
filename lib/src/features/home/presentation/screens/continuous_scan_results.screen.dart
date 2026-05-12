
import 'package:flutter/material.dart';

class ContinuousScanResultScreen extends StatefulWidget {
  final List<String>? result;
  const ContinuousScanResultScreen({super.key, required this.result});

  @override
  State<ContinuousScanResultScreen> createState() => _ContinuousScanResultScreenState();
}

class _ContinuousScanResultScreenState extends State<ContinuousScanResultScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.result!.length,
            itemBuilder: (context, index){
              return ListTile(
                title: Text(widget.result![index]),
              );
            },
          ),

        ],
      ),
    );
  }
}
