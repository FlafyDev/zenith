import 'dart:ui';

import 'package:zenith/enums.dart';
import 'package:zenith/util/util.dart';
import 'package:zenith/widgets/popup.dart';
import 'package:zenith/state/popup_state.dart';
import 'package:zenith/widgets/window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zenith/state/window_state.dart';

class DesktopState with ChangeNotifier {
  List<Window> windows = [];
  List<Popup> popups = [];

  static const EventChannel windowMappedEvent = EventChannel('window_mapped');
  static const EventChannel windowUnmappedEvent = EventChannel('window_unmapped');
  static const EventChannel popupMappedEvent = EventChannel('popup_mapped');
  static const EventChannel popupUnmappedEvent = EventChannel('popup_unmapped');
  static const EventChannel requestMoveEvent = EventChannel('request_move');
  static const EventChannel requestResizeEvent = EventChannel('request_resize');
  static const EventChannel configureSurfaceEvent = EventChannel('configure_surface');

  static const MethodChannel platform = MethodChannel('platform');

  Offset pointerPosition = window.physicalGeometry.center;

  DesktopState() {
    windowMappedEvent.receiveBroadcastStream().listen(windowMapped);
    windowUnmappedEvent.receiveBroadcastStream().listen(windowUnmapped);
    popupMappedEvent.receiveBroadcastStream().listen(popupMapped);
    popupUnmappedEvent.receiveBroadcastStream().listen(popupUnmapped);
    requestMoveEvent.receiveBroadcastStream().listen(requestMove);
    requestResizeEvent.receiveBroadcastStream().listen(requestResize);
    configureSurfaceEvent.receiveBroadcastStream().listen(configureSurface);
  }

  void windowMapped(dynamic event) {
    int viewId = event["view_id"];
    int surfaceWidth = event["surface_width"];
    int surfaceHeight = event["surface_height"];

    // Visible bounds relative to (0, 0) being the top left corner of the surface.
    var visibleBoundsMap = Map<String, int>.from(event["visible_bounds"]);
    var visibleBounds = Rect.fromLTWH(
      visibleBoundsMap["x"]!.toDouble(),
      visibleBoundsMap["y"]!.toDouble(),
      visibleBoundsMap["width"]!.toDouble(),
      visibleBoundsMap["height"]!.toDouble(),
    );

    var initialWindowPosition = Rect.fromCenter(
      center: pointerPosition,
      width: visibleBounds.width,
      height: visibleBounds.height,
    );
    initialWindowPosition = initialWindowPosition.clampTo(window.physicalGeometry);

    windows.add(
      Window(WindowState(
        viewId: viewId,
        title: "Window",
        position: initialWindowPosition.topLeft,
        surfaceSize: Size(surfaceWidth.toDouble(), surfaceHeight.toDouble()),
        visibleBounds: visibleBounds,
      )),
    );
    notifyListeners();
  }

  void windowUnmapped(dynamic event) async {
    int viewId = event["view_id"];

    var window = windows.singleWhere((element) => element.state.viewId == viewId);

    if (window == windows.last && windows.length >= 2) {
      // Activate the window behind.
      var penultimate = windows[windows.length - 2];
      platform.invokeMethod('activate_window', penultimate.state.viewId);
    }

    await window.state.animateClosing();

    windows.remove(window);
    notifyListeners();
  }

  void popupMapped(dynamic event) {
    int viewId = event["view_id"];
    int parentViewId = event["parent_view_id"];
    int x = event["x"];
    int y = event["y"];
    int width = event["surface_width"];
    int height = event["surface_height"];
    var visibleBoundsMap = event["visible_bounds"];
    var visibleBounds = Rect.fromLTWH(
      visibleBoundsMap["x"]!.toDouble(),
      visibleBoundsMap["y"]!.toDouble(),
      visibleBoundsMap["width"]!.toDouble(),
      visibleBoundsMap["height"]!.toDouble(),
    );

    // Parent can be either a window or another popup.
    Offset parentPosition;
    var windowIndex = windows.indexWhere((element) => element.state.viewId == parentViewId);
    if (windowIndex != -1) {
      var window = windows[windowIndex];
      parentPosition = window.state.position;
    } else {
      var popupIndex = popups.indexWhere((element) => element.state.viewId == parentViewId);
      var popup = popups[popupIndex];
      parentPosition = popup.state.position;
    }

    var popup = Popup(PopupState(
      viewId: viewId,
      parentViewId: parentViewId,
      position: Offset(x + parentPosition.dx, y + parentPosition.dy),
      surfaceSize: Size(width.toDouble(), height.toDouble()),
      visibleBounds: visibleBounds,
    ));

    popups.add(popup);
    notifyListeners();
  }

  void popupUnmapped(dynamic event) async {
    int viewId = event["view_id"];

    var popup = popups.singleWhere((element) => element.state.viewId == viewId);
    await popup.state.animateClosing();

    popups.remove(popup);
    notifyListeners();
  }

  void requestMove(dynamic event) {
    int viewId = event["view_id"];

    var window = windows.singleWhere((element) => element.state.viewId == viewId);
    window.state.startMove();
  }

  void requestResize(dynamic event) {
    int viewId = event["view_id"];
    int edges = event["edges"];

    var window = windows.singleWhere((element) => element.state.viewId == viewId);
    window.state.startResize(edges);
  }

  void configureSurface(dynamic event) {
    int viewId = event["view_id"];
    var role = XdgSurfaceRole.values[event["surface_role"]];

    Size? newSurfaceSize;
    if (event["surface_size_changed"]) {
      int surfaceWidth = event["surface_width"];
      int surfaceHeight = event["surface_height"];
      newSurfaceSize = Size(surfaceWidth.toDouble(), surfaceHeight.toDouble());
    }

    Rect? newVisibleBounds;
    if (event["geometry_changed"]) {
      var visibleBoundsMap = event["visible_bounds"];
      newVisibleBounds = Rect.fromLTWH(
        visibleBoundsMap["x"]!.toDouble(),
        visibleBoundsMap["y"]!.toDouble(),
        visibleBoundsMap["width"]!.toDouble(),
        visibleBoundsMap["height"]!.toDouble(),
      );
    }

    Offset? newPosition;
    if (role == XdgSurfaceRole.popup && event["popup_position_changed"]) {
      int x = event["x"];
      int y = event["y"];
      newPosition = Offset(x.toDouble(), y.toDouble());
    }

    switch (role) {
      case XdgSurfaceRole.toplevel:
        var window = windows.singleWhere((element) => element.state.viewId == viewId);

        if (newVisibleBounds != null) {
          // Window position will change if it's resized from the left or top.
          var position = window.state.position;
          var visibleBounds = window.state.visibleBounds;

          double x = Edges.left & window.state.resizingEdges
              ? position.dx + (visibleBounds.width - newVisibleBounds.width)
              : position.dx;

          double y = Edges.top & window.state.resizingEdges
              ? position.dy + (visibleBounds.height - newVisibleBounds.height)
              : position.dy;

          window.state.position = Offset(x, y);
        }

        window.state.surfaceSize = newSurfaceSize ?? window.state.surfaceSize;
        window.state.visibleBounds = newVisibleBounds ?? window.state.visibleBounds;
        break;

      case XdgSurfaceRole.popup:
        var popup = popups.singleWhere((element) => element.state.viewId == viewId);
        popup.state.surfaceSize = newSurfaceSize ?? popup.state.surfaceSize;
        popup.state.visibleBounds = newVisibleBounds ?? popup.state.visibleBounds;

        Offset parentPosition;
        var windowIndex = windows.indexWhere((element) => element.state.viewId == popup.state.parentViewId);
        if (windowIndex != -1) {
          // Parent is a window.
          var window = windows[windowIndex];
          parentPosition = window.state.position;
        } else {
          // Parent is another popup.
          var popupIndex = popups.indexWhere((element) => element.state.viewId == popup.state.parentViewId);
          var parentPopup = popups[popupIndex];
          parentPosition = parentPopup.state.position;
        }

        if (event["popup_position_changed"]) {
          // Position relative to the parent.
          int x = event["x"];
          int y = event["y"];
          newPosition = Offset(x.toDouble(), y.toDouble());
          popup.state.position = newPosition + parentPosition;
        }
        break;

      case XdgSurfaceRole.none:
        assert(false, "xdg_surface has no role, this should never happen.");
        break;
    }
  }

  void activateWindow(int viewId) {
    var window = windows.singleWhere((window) => window.state.viewId == viewId);
    // Put it in the front.
    windows.remove(window);
    windows.add(window);

    platform.invokeMethod('activate_window', window.state.viewId);
    notifyListeners();
  }

  void destroyWindow(Window window) {
    windows.remove(window);
    notifyListeners();
  }
}
