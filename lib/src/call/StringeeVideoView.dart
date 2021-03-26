import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'CallConstants.dart';

class StringeeVideoView extends StatefulWidget {
  StringeeVideoView({
    Key? key,
    required this.callId,
    this.isLocal = true,
    this.isOverlay = false,
    this.isMirror = false,
    this.color,
    this.height,
    this.width,
    this.margin,
    this.alignment,
    this.padding,
    this.child,
    this.scalingType,
  })  : assert(margin == null || margin.isNonNegative),
        assert(padding == null || padding.isNonNegative),
        super(key: key);

  final String callId;
  final bool isLocal;
  final bool isOverlay;
  final bool isMirror;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final ScalingType? scalingType;
  final double? height;
  final double? width;
  final Color? color;
  final Widget? child;

  @override
  StringeeVideoViewState createState() => StringeeVideoViewState();
}

class StringeeVideoViewState extends State<StringeeVideoView> {
  // This is used in the platform side to register the view.
  final String viewType = 'stringeeVideoView';

  // Pass parameters to the platform side.
  Map<dynamic, dynamic> creationParams = <dynamic, dynamic>{};

  @override
  void initState() {
    super.initState();

    creationParams = <String, dynamic>{
      'callId': widget.callId,
      'isLocal': widget.isLocal,
      'isOverlay': widget.isOverlay,
    };

    switch (widget.scalingType) {
      case ScalingType.SCALE_ASPECT_FILL:
        creationParams['scalingType'] = 'FILL';
        break;
      case ScalingType.SCALE_ASPECT_FIT:
        creationParams['scalingType'] = 'FIT';
        break;
      default:
        creationParams['scalingType'] = 'BALANCED';
        break;
    }

    if (Platform.isAndroid) {
      creationParams['isMirror'] = widget.isMirror;
    }
  }

  Widget createVideoView() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PlatformViewLink(
          viewType: viewType,
          surfaceFactory:
              (BuildContext context, PlatformViewController controller) {
            return PlatformViewSurface(
              controller: controller,
              gestureRecognizers: const <
                  Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.rtl,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> childrenWidget = <Widget>[];
    childrenWidget.add(createVideoView());

    Widget current = Container(
      height: widget.height,
      width: widget.width,
      color: widget.color,
      margin: widget.margin,
      child: Stack(
        children: childrenWidget,
      ),
    );

    if (widget.child != null) {
      Widget child = widget.child!;

      if (widget.padding != null) {
        child = Padding(padding: widget.padding!, child: child);
      }

      childrenWidget.add(child);
    }

    if (widget.alignment != null) {
      current = Align(alignment: widget.alignment!, child: current);
    }

    return current;
  }
}
