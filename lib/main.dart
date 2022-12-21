import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith/platform_api.dart';
import 'package:zenith/state/display_brightness_state.dart';
import 'package:zenith/state/lock_screen_state.dart';
import 'package:zenith/widgets/desktop.dart';

void main() {
  // FIXME: FlutterEngineMarkExternalTextureFrameAvailable does not trigger a VSync fast enough,
  // so Flutter will only VSync every second frame. Marking a texture after FlutterEngineOnVsync
  // only fixes the problem partially because Flutter will still skip frames every once in a while.
  // This forces Flutter to always schedule a new frame.
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addPersistentFrameCallback((_) {
    WidgetsBinding.instance.scheduleFrame();
  });

  SchedulerBinding.instance.addPostFrameCallback((_) {
    PlatformApi.startupComplete();
  });

  final container = ProviderContainer();

  _registerLockScreenKeyboardHandler(container);
  _registerPowerButtonHandler(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: Zenith(),
    ),
  );
}

const _notchHeight = 80.0; // physical pixels

class Zenith extends ConsumerWidget {
  final GlobalKey<OverlayState> overlayKey = GlobalKey();

  Zenith({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      lockScreenStateProvider.select((v) => v.overlayEntryInserted),
      (_, bool insert) {
        if (insert) {
          overlayKey.currentState?.insert(ref.read(lockScreenStateProvider).overlayEntry);
        } else {
          ref.read(lockScreenStateProvider).overlayEntry.remove();
        }
      },
    );

    // FIXME:
    // We cannot use MaterialApp because it somehow captures the arrow keys and tab automatically,
    // therefore these keys don't get forwarded to the Wayland client.
    // Let's use a WidgetApp for now. We cannot anymore select UI elements via the keyboard, but we
    // don't care about that on a mobile phone.
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
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: EdgeInsets.only(
                top: _notchHeight / MediaQuery.of(context).devicePixelRatio,
              ),
            ),
            child: Scaffold(
              body: Overlay(
                key: overlayKey,
                initialEntries: [
                  OverlayEntry(builder: (_) => const Desktop()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void _registerLockScreenKeyboardHandler(ProviderContainer container) {
  HardwareKeyboard.instance.addHandler((KeyEvent keyEvent) {
    if (container.read(lockScreenStateProvider).locked) {
      // We don't want to send keyboard events to Wayland clients when the screen
      // is locked. Capture all keyboard events.
      return true;
    }
    return false;
  });
}

void _registerPowerButtonHandler(ProviderContainer container) {
  bool screenOn = true;
  HardwareKeyboard.instance.addHandler((KeyEvent keyEvent) {
    if (keyEvent.logicalKey == LogicalKeyboardKey.powerOff) {
      if (keyEvent is KeyDownEvent) {
        final displayBrightnessStateProviderNotifier = container.read(displayBrightnessStateProvider.notifier);
        final displayBrightnessState = container.read(displayBrightnessStateProvider);

        if (screenOn) {
          Future<void> turnScreenOff() async {
            container.read(lockScreenStateProvider.notifier).lock();

            if (displayBrightnessState.available) {
              try {
                displayBrightnessStateProviderNotifier.saveBrightness();
                await displayBrightnessStateProviderNotifier.setBrightness(0);
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  // Wait for the lock screen to appear betfore we stop rendering.
                  PlatformApi.enableDisplay(false);
                });
                screenOn = false;
              } catch (_) {}
            }
          }

          turnScreenOff();
        } else {
          Future<void> turnScreenOn() async {
            if (displayBrightnessState.available) {
              try {
                await PlatformApi.enableDisplay(true);
                await displayBrightnessStateProviderNotifier.restoreBrightness();
                screenOn = true;
              } catch (_) {}
            }
          }

          turnScreenOn();
        }
      }
      return true;
    }
    return false;
  });
}
