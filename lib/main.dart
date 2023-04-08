import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:zenith/platform_api.dart';
import 'package:zenith/zenith/window_manager.dart';

void main() {
  // debugRepaintRainbowEnabled = true;
  // debugPrintGestureArenaDiagnostics = true;
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final channel = container.read(compositorPlatformApi);

  SchedulerBinding.instance.addPostFrameCallback((_) {
    channel.invokeMethod("startup_complete");
  });

  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const Zenith(),
    ),
  );
}

final screenSizeProvider = StateProvider<Size>((ref) {
  return const Size(0, 0);
});

class Zenith extends HookConsumerWidget {
  const Zenith({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIXME:
    // We cannot use MaterialApp because it somehow captures the arrow keys and tab automatically,
    // therefore these keys don't get forwarded to the Wayland client.
    // Let's use a WidgetApp for now. We cannot anymore select UI elements via the keyboard, but we
    // don't care about that on a mobile phone.
    return LayoutBuilder(builder: (context, constraints) {
      Future.microtask(() => ref.read(screenSizeProvider.notifier).state = constraints.biggest);
      return WidgetsApp(
        color: Colors.blue,
        builder: (BuildContext context, Widget? child) {
          return ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              // Enable scrolling by dragging the mouse cursor.
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
                PointerDeviceKind.invertedStylus,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.unknown,
              },
            ),
            child: Scaffold(
              body: Container(
                width: constraints.biggest.width,
                height: constraints.biggest.height,
                decoration: const BoxDecoration(
                  // gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blueGrey,
                      Colors.lightBlue,
                    ],
                  ),
                  color: Colors.black,
                ),
                child: const WindowManager(),
              ),
            ),
          );
        },
      );
    });
  }
}
