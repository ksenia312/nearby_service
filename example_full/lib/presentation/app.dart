import 'package:flutter/material.dart';
import 'package:nearby_service_example_full/domain/app_service.dart';
import 'package:nearby_service_example_full/domain/app_state.dart';
import 'package:provider/provider.dart';

import 'builder/app_step_view_builder.dart';
import 'components/info_panel.dart';

const kPinkColor = Color(0xFFC80099);
const kBlueColor = Color(0xFF0043D5);
const kWhiteColor = Color(0xFFFFFFFF);
const kGreyColor = Color(0xFF607D8B);
const kGreenColor = Color(0xFF07B988);

class App extends StatelessWidget {
  const App({super.key, required this.service});

  final AppService service;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: service,
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kBlueColor),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Nearby service example app'),
            actions: [
              Builder(builder: (context) {
                return IconButton(
                  onPressed: () => InfoPanel.show(context),
                  icon: const Icon(Icons.info_outline),
                );
              }),
            ],
          ),
          body: Consumer<AppService>(builder: (context, service, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: InfoPanel(),
                ),
                Flexible(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeLeft: true,
                    child: Stepper(
                      controlsBuilder: (context, _) => const SizedBox.shrink(),
                      currentStep: service.state.step,
                      steps: [
                        ...AppState.steps.map((e) {
                          final builder = AppStepViewBuilder(state: e);
                          final isActive = e == service.state;
                          return Step(
                            state: isActive
                                ? StepState.indexed
                                : e.step < service.state.step
                                    ? StepState.complete
                                    : StepState.disabled,
                            title: builder.buildTitle(),
                            subtitle: builder.buildSubtitle(),
                            content: builder.buildContent(),
                            isActive: isActive,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
