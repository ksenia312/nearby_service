import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/uikit/uikit.dart';
import 'package:provider/provider.dart';

class SelectClientTypeView extends StatelessWidget {
  const SelectClientTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActionButton(
          title: 'Yes',
          onTap: () {
            context.read<AppService>().setIsBrowser(value: true);
          },
        ),
        const SizedBox(width: 10),
        ActionButton(
          title: 'No',
          onTap: () {
            context.read<AppService>().setIsBrowser(value: false);
          },
        ),
      ],
    );
  }
}
