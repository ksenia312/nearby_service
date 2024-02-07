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

class App extends StatefulWidget {
  const App({super.key, required this.service});

  final AppService service;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.service,
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kBlueColor),
        ),
        home: Scaffold(
          key: scaffoldKey,
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
          body: _AppBody(scaffoldKey),
        ),
      ),
    );
  }
}

class _AppBody extends StatelessWidget {
  const _AppBody(this.scaffoldKey);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Selector<AppService, AppState>(
      selector: (context, service) => service.state,
      builder: (context, state, _) {
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
                  currentStep: state.step,
                  steps: [
                    ...AppState.steps.map(
                      (e) {
                        final builder = AppStepViewBuilder(state: e);
                        final isActive = e == state;
                        return Step(
                          isActive: isActive,
                          title: builder.buildTitle(),
                          subtitle: builder.buildSubtitle(),
                          content: builder.buildContent(
                            scaffoldKey: scaffoldKey,
                          ),
                          state: isActive
                              ? StepState.indexed
                              : e.step < state.step
                                  ? StepState.complete
                                  : StepState.disabled,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
