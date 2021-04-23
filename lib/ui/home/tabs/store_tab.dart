import 'dart:convert';

import 'package:cobble/ui/router/cobble_scaffold.dart';
import 'package:cobble/ui/router/cobble_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StoreTab extends StatefulWidget implements CobbleScreen {
  @override
  State<StatefulWidget> createState() => new _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  late WebViewController controller;
  @override
  Widget build(BuildContext context) {
    return CobbleScaffold.tab(
      child: WebView(
        initialUrl:
            "https://store-beta.rebble.io/?native=true&platform=android",
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) async {
          if (request.url.startsWith('pebble://appstore')) {
            var uuid = request.url.substring(18, 42);
            debugPrint('uuid: $uuid');
            Uri url = Uri.parse(
                "https://appstore-api.rebble.io/api/v1/apps/id/$uuid");
            Response response = await get(url);
            Map<String, dynamic> json = jsonDecode(response.body);
            var pbw = json['data'][0]['latest_release']['pbw_file'];
            _launchURL(pbw);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
