import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/widgets/connection_card.widget.dart';

class ConnectionClientScreen extends StatefulWidget {
  final String name;
  const ConnectionClientScreen({super.key, required this.name, required String clientVendorId});

  @override
  State<ConnectionClientScreen> createState() => _ConnectionClientScreenState();
}

class _ConnectionClientScreenState extends State<ConnectionClientScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back_ios_new_rounded,
        title: widget.name,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.ssm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.0,
            children: <Widget>[
              ConnectionCard(
                connection: "+94 123 456 789",
                expDate: '2023-11-01',
                packageName: "Premium 5G",
                status: 1,
              ),
              ConnectionCard(
                connection: "+94 123 456 789",
                expDate: '2023-11-01',
                packageName: "Premium 5G",
                status: 1,
              ),

            ],
          ),
        ),
      ),
    );
  }

}
