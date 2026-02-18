import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oxoo/screen/subscription/choose_plan_screen.dart';
import 'package:oxoo/screen/subscription/premium_subscription_screen.dart';
import '../../style/theme.dart';
import 'package:hive/hive.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config.dart';
import '../constants.dart';
import '../strings.dart';

// ignore: must_be_immutable
class TermsPolices extends StatefulWidget {
  static final String route = "TermsPolices";
  static bool isDark  = Hive.box('appModeBox').get('isDark')??false;

  @override
  State<TermsPolices> createState() => _TermsPolicesState();
}

class _TermsPolicesState extends State<TermsPolices> {
  late WebViewController? controller;
  String _url = Config.termsPolicyUrl;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      // WebView.platform = SurfaceAndroidWebView();
    }

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          // Handle the message received from JavaScript
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
          printLog('JavaScript message received: ${message.message}');
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            printLog('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            printLog('Page started loading: $url');
          },
          onPageFinished: (String url) {
            printLog('Page finished loading: $url');
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            if (request.url
                .startsWith("https://checkout.stripe.dev/success")) {
              printLog("stripe payment successfully");
              // Save payment data
              // savePaymentData();
            } else if (request.url
                .startsWith("https://checkout.stripe.dev/cancel")) {
              // Payment failed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Payment unsuccessful.")),
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => PremiumSubscriptionScreen()),
              // );
              if(Config.inAppPurchaseActivated){
                Navigator.push(context, MaterialPageRoute(builder: (context) => PremiumSubscriptionScreen()));
              }else{
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChoosePlanScreen()));
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setBackgroundColor(Color(0x00000000))
      ..loadRequest(Uri.parse(_url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.termsPolicy),
        iconTheme: IconThemeData(
          color: TermsPolices.isDark ? CustomTheme.primaryColorRed : CustomTheme.primaryColorDark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 24,
          color: TermsPolices.isDark ? CustomTheme.primaryColorRed : CustomTheme.primaryColorDark,
        ),
        backgroundColor:TermsPolices.isDark? CustomTheme.colorAccentDark:CustomTheme.primaryColor,
      ),
      body: WebViewWidget(
      // initialUrl: snapshot.data,
      // // javascriptMode: JavascriptMode.unrestricted,
      // onWebViewCreated: (WebViewController webViewController) {
      //   _controller.complete(webViewController);
      // },
      // onProgress: (int progress) {
      //   print('WebView is loading (progress : $progress%)');
      // },
      //Rimon
      // javascriptChannels: <JavascriptChannel>{
      //   _toasterJavascriptChannel(context),
      // },
      // navigationDelegate: (NavigationRequest request) {
      //   if (request.url.startsWith('https://www.youtube.com/')) {
      //     print('blocking navigation to $request}');
      //     return NavigationDecision.prevent;
      //   }
      //   print('allowing navigation to $request');
      //   if (request.url
      //       .startsWith("https://checkout.stripe.dev/success")) {
      //     printLog("stripe payment successfully");
      //     //save payment data
      //     savePaymentData();
      //   } else if (request.url
      //       .startsWith("https://checkout.stripe.dev/cancel")) {
      //     //payment failed
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text("Payment unsuccessful.")),
      //     );
      //     Navigator.of(context).pushReplacement(MaterialPageRoute(
      //       builder: (context) => ChoosePlanScreen(),
      //     ));
      //   }
      //   return NavigationDecision.navigate;
      // },
      // onPageStarted: (String url) {
      //   print('Page started loading: $url');
      // },
      // onPageFinished: (String url) {
      //   print('Page finished loading: $url');
      // },
      // gestureNavigationEnabled: true,
      // backgroundColor: const Color(0x00000000),
      controller: controller!,
    ),
    );
  }
}
