import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/screens/seed_data/package_seed_data.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_elevated_button.widget.dart';

class SeederScreen extends StatefulWidget {
  const SeederScreen({super.key});

  @override
  State<SeederScreen> createState() => _SeederScreenState();
}

class _SeederScreenState extends State<SeederScreen> {
  bool loading = false;

  Future<void> insertPackages() async {
    setState(() => loading = true);

    // final firestore = FirebaseFirestore.instance;

    try {
      // for (final package in packages) {
      //   await firestore.collection("package_details").add(package);
      // }

      final batch = FirebaseFirestore.instance.batch();

      for (final package in packages) {
        final doc = FirebaseFirestore.instance
            .collection("package_details")
            .doc();

        batch.set(doc, package);
      }

      await batch.commit();

      if (mounted) {
        AppSnackbar.showSuccess(context, "Packages inserted successfully");
      }
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        AppSnackbar.showError(context, e.toString());
      }
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insert Dummy Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.lg, horizontal: Sizes.md),
        child: Column(
          children: [
            CElevatedButton(
              onPressed: insertPackages,
              isLoading: loading,
              label: "Insert Packages",
            ),
          ],
        ),
      ),
    );
  }
}

