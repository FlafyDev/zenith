import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:zenith/zenith/window_manager.dart';

void main() {
  // debugRepaintRainbowEnabled = true;
  // debugPrintGestureArenaDiagnostics = true;
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  SchedulerBinding.instance.addPostFrameCallback((_) {
    const MethodChannel("platform").invokeMethod("startup_complete");
  });

  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  Process.run("touch", [
    "/home/flafy/testfile"
  ]);

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
    final mytest = useState(false);

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
                // decoration: const BoxDecoration(
                //   // gradient
                //   gradient: LinearGradient(
                //     begin: Alignment.topLeft,
                //     end: Alignment.bottomRight,
                //     colors: [
                //       Colors.red,
                //       Colors.blue,
                //       Colors.red,
                //       Colors.blue,
                //       Colors.red,
                //       Colors.blue,
                //       Colors.red,
                //       Colors.blue,
                //       Colors.red,
                //       Colors.blue,
                //     ],
                //   ),
                //   color: Colors.black,
                // ),
                child: Stack(
                  children: [
                    Positioned(
                      width: 1920,
                      height: 1080,
                      child: Container(color: Colors.green),
                      // child: Image.asset("assets/images/background.jpg"),
                    ),
                    // const Positioned.fill(
                    //   child: WindowManager(),
                    // ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        color: Colors.red,
                        width: 200,
                        height: 200,
                        child: GestureDetector(
                          onTap: () {
                            mytest.value = !mytest.value;
                          },
                          child: Center(
                            child: mytest.value
                                ? const Text(
                                    'AAAAAAAAAAAAAAAA',
                                    style: TextStyle(fontSize: 24),
                                  )
                                : const Text(
                                    'BBBBBBBBB',
                                    style: TextStyle(fontSize: 24),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    // const WindowManager(),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
