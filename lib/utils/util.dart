import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:web3modal_flutter/models/launch_url_exception.dart';
import 'package:web3modal_flutter/utils/core_util.dart';
import 'package:web3modal_flutter/utils/logger_util.dart';

enum PlatformType {
  mobile,
  desktop,
  web,
}

class Util {
  static PlatformType getPlatformType() {
    if (Platform.isAndroid || Platform.isIOS) {
      return PlatformType.mobile;
    } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return PlatformType.desktop;
    } else if (kIsWeb) {
      return PlatformType.web;
    }
    return PlatformType.mobile;
  }

  static bool isMobileWidth(BuildContext context) {
    return MediaQuery.of(context).size.width <= 400.0;
  }

  /// Detects if the given app (Represented by the URI) is installed.
  /// If on android/ios, this uses the AppCheck library.
  /// On web, this uses the injected values in the Javascript.
  static Future<bool> isInstalled(String uri) async {
    if (uri.isEmpty) {
      return false;
    }

    try {
      return getPlatformType() == PlatformType.mobile &&
          await canLaunchUrl(
            Uri.parse(
              uri,
            ),
          );
    } catch (_) {
      // print(e);
    }

    return false;
  }

  // static Future<void> launchApp(
  //   String universalUri,
  //   String nativeLink,
  //   String wcUri,
  // ) async {
  //   if (getPlatformType() == PlatformType.mobile) {
  //     await AppCheck.launchApp(uri);
  //   }
  // }

  static Future<void> navigateDeepLink({
    String? deepLink,
    String? universalLink,
    required String wcURI,
  }) async {
    // Construct the link
    final Uri? nativeUri = CoreUtil.formatNativeUrl(
      deepLink,
      wcURI,
    );
    final Uri? universalUri = CoreUtil.formatUniversalUrl(
      universalLink,
      wcURI,
    );
    LoggerUtil.logger.v(
      'Navigating deep links. Native: ${nativeUri.toString()}, Universal: ${universalUri.toString()}',
    );
    LoggerUtil.logger.v(
      'Deep Link Query Params. Native: ${nativeUri?.queryParameters}, Universal: ${universalUri?.queryParameters}',
    );

    // Launch the link
    if (nativeUri != null) {
      LoggerUtil.logger.v(
        'Navigating deep links. Launching native URI.',
      );
      try {
        await launchUrl(nativeUri);
      } catch (e) {
        LoggerUtil.logger.i(
          'Navigating deep links. Launching native failed, launching universal URI.',
        );
        // Fallback to universal link
        if (universalUri != null) {
          await launchUrl(universalUri);
        } else {
          throw LaunchUrlException('Unable to open the wallet');
        }
      }
    } else if (universalUri != null) {
      LoggerUtil.logger.i(
        'Navigating deep links. Launching universal URI.',
      );
      await launchUrl(universalUri);
    } else {
      throw LaunchUrlException('Unable to open the wallet');
    }
  }
}
