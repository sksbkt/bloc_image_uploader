import 'dart:async';

import 'package:bloc_image_uploader/loading/loading_screen_controller.dart';
import 'package:flutter/material.dart';

class LoadingScreen {
  //?singleton patter
  LoadingScreen._sharedInstance();
  static late final LoadingScreen _shared = LoadingScreen._sharedInstance();
  factory LoadingScreen.instance() => _shared;

  LoadingScreenController? _controller;

  void show({
    required BuildContext context,
    required String text,
  }) {
    if (_controller?.update(text) ?? false) {
      return;
    } else {
      _controller = _showOverlay(
        context: context,
        text: text,
      );
    }
  }

  void hide() {
    _controller?.close();
    _controller = null;
  }

  LoadingScreenController _showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final streamText = StreamController<String>();
    streamText.add(text);

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * .8,
                maxHeight: size.height * .8,
                minWidth: size.width * .5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: SingleChildScrollView(
                  child: Column(
                    //?so the column wont take the entire screen height space
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const CircularProgressIndicator(),
                      const SizedBox(
                        height: 10,
                      ),
                      StreamBuilder<String>(
                        stream: streamText.stream,
                        builder: (context, snapShot) {
                          if (snapShot.hasData) {
                            return Text(
                              snapShot.data!,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    state?.insert(overlay);
    return LoadingScreenController(
      close: () {
        streamText.close();
        overlay.remove();
        return true;
      },
      update: (text) {
        streamText.add(text);
        return true;
      },
    );
  }
}
