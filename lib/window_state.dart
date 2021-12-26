import 'dart:async';

import 'package:flutter/material.dart';

class WindowState with ChangeNotifier {
  WindowState({
    required this.viewId,
    required String title,
    required Offset position,
    required this.surfaceSize,
    required this.visibleBounds,
  })  : _position = position,
        _title = title {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // We cannot call this function directly because the window will not animate otherwise.
      animateOpening();
    });
  }

  final int viewId;
  final GlobalKey textureKey = GlobalKey();
  String _title;

  Offset _position;
  Size surfaceSize;
  Rect visibleBounds;

  bool isClosing = false;
  bool isMoving = false;
  Offset movingDelta = Offset.zero;

  double scale = 0.9;
  double opacity = 0.5;
  var windowClosed = Completer<void>();

  // var popups = <Popup>[];

  String get title => _title;

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  Offset get position => _position;

  set position(Offset value) {
    _position = value;
    notifyListeners();
  }

  void animateOpening() {
    scale = 1.0;
    opacity = 1.0;
    notifyListeners();
  }

  Future animateClosing() {
    isClosing = true;
    scale = 0.9;
    opacity = 0.0;
    notifyListeners();
    return windowClosed.future;
  }

  void startMove() {
    isMoving = true;
    movingDelta = Offset.zero;
    notifyListeners();
  }

  void stopMove() {
    if (isMoving) {
      isMoving = false;
      movingDelta = Offset.zero;
      notifyListeners();
    }
  }
}
