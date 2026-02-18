import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:oxoo/screen/landing_screen.dart';
import '../../constants.dart';
import '../../models/user_model.dart';
import '../../server/repository.dart';
import '../../service/authentication_service.dart';
import '../../style/theme.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../config.dart';
import '../../strings.dart';
import 'my_subscription_screen.dart';

// In-app purchase product IDs
const List<String> _kProductIds = <String>[
  'com.oxoo.7',
  'com.oxoo.30',
  'com.oxoo.90',
  'com.oxoo.180',
  'com.oxoo.365',
  'com.oxoo.premium',
];

class PremiumSubscriptionScreen extends StatefulWidget {
  static final String route = '/PremiumSubscriptionScreen';
  final bool? fromRadioScreen;
  final bool? fromLiveTvScreen;
  final String? radioId;
  final String? liveTvID;
  final String? isPaid;

  const PremiumSubscriptionScreen({
    Key? key,
    this.fromRadioScreen,
    this.fromLiveTvScreen,
    this.radioId,
    this.liveTvID,
    this.isPaid,
  }) : super(key: key);

  @override
  _PremiumSubscriptionScreenState createState() => _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen> {
  String? widgetplanId;
  String? currentProductPrice;
  String? currentPlanID;
  int popCount = 0;
  double? screenWidth;
  late bool isDark;
  AuthUser? authUser = AuthService().getUser();
  var appModeBox = Hive.box('appModeBox');
  bool isUserValidSubscriber = false;

  // In-app purchase variables
  final InAppPurchase _connection = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    isDark = appModeBox.get('isDark') ?? false;
    _subscription = _connection.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription.cancel(),
      onError: (error) => print("Error in purchase stream: $error"),
    );
    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _loading = false;
      });
      return;
    }

    //new rimon
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = _connection.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse = await _connection.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null || productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _loading = false;
      });
      return;
    }

    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = [];
      _notFoundIds = productDetailResponse.notFoundIDs;
      _loading = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    if (Platform.isAndroid) {
      return Repository().verifyMarketInApp(
        signature: purchaseDetails.purchaseID,
        signedData: purchaseDetails.verificationData.localVerificationData,
        publicKey: Config.publicKeyBase64,
      );
    }
    return true;
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    print("listen to purchase");
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        print("purchase status success");
        // _verifyPurchase(purchaseDetails).then((isValid) {
        //   if (isValid) {
        //     deliverProduct(purchaseDetails);
        await Repository()
            .saveChargeData(
            planID: purchaseDetails.purchaseID,
            userId: authUser!.userId.toString(),
            paidAmount: currentProductPrice,
            paymentMethod: "In App Purchase",
            paymentInfo: "")
            .then((value) {
          // Navigator.of(context).pushReplacement(MaterialPageRoute(
          //   builder: (context) => MySubscriptionScreen(),
          // ));
          Navigator.of(context).popUntil((_) => popCount++ >= 2);
        });
          // } else {
          //   _handleInvalidPurchase(purchaseDetails);
          // }
        // });
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        handleError(purchaseDetails.error);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }

  void deliverProduct(PurchaseDetails purchaseDetails) {
    setState(() {
      _purchases.add(purchaseDetails);
      appModeBox.put('isUserValidSubscriber', true);
    });
    _handlePaymentSuccess(purchaseDetails);
  }

  void showPendingUI() {
    setState(() {});
  }

  void handleError(IAPError? error) {
    print("Purchase error: $error");
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    print("Invalid purchase detected.");
  }

  void _handlePaymentSuccess(PurchaseDetails purchaseDetails) {
    print("handle payment success");
    onSuccess(purchaseDetails.productID, authUser!.userId.toString(), currentProductPrice.toString());
  }

  Future<void> onSuccess(String planId,String userId, String price) async {
    print("on success method");
    await Repository()
        .saveChargeData(
        planID: planId,
        userId: userId,
        paidAmount: price,
        paymentMethod: "in app purchase",
        paymentInfo: "")
        .then((value) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LandingScreen()), (Route<dynamic> route) => false);
      // Navigator.of(context).popUntil((_) => popCount++ >= 2);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: isDark ? CustomTheme.primaryColorRed : CustomTheme.primaryColorDark),
        titleTextStyle: TextStyle(fontSize: 24, color: isDark ? CustomTheme.primaryColorRed : CustomTheme.primaryColorDark),
        backgroundColor: isDark ? Colors.black : CustomTheme.primaryColor,
        title: Image.asset('assets/logo.png', scale: 12.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Text(AppContent.confirmYourDetails, style: CustomTheme.bodyText1),
              SizedBox(height: 20.0),
              _buildUserDetailsCard(),
              SizedBox(height: 20.0),
              _buildSubscriptionOptions(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildUserDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildDetailLabel(AppContent.plan),
              _buildDetailValue(AppContent.watchPremiumVideo),
            ],
          ),
          Divider(),
          Row(
            children: [
              _buildDetailLabel(AppContent.email),
              _buildDetailValue(authUser!.email!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailLabel(String label) {
    return Container(
      width: MediaQuery.of(context).size.width / 3,
      padding: const EdgeInsets.all(8.0),
      child: Text(label, style: CustomTheme.bodyText1),
    );
  }

  Widget _buildDetailValue(String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(value, style: CustomTheme.authTitleGrey),
      ),
    );
  }

  Widget _buildSubscriptionOptions() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          _buildProductList(),
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(AppContent.startStreamingNow, style: CustomTheme.authTitleGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.separated(
      separatorBuilder: (context,index)=>Divider(),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ListTile(
          title: Text(product.title, style: CustomTheme.bodyText1),
          subtitle: Text(product.description, style: CustomTheme.authTitleGrey),
          trailing: Text(product.price, style: CustomTheme.bodyText1),
          onTap: () {
            print("tap for purchase");
            currentProductPrice = "";
            currentProductPrice = product.price;
            String numericPart = currentProductPrice == null ? "0" : currentProductPrice.toString().replaceAll(RegExp(r'[^\d.]'), '');
            double priceValue = double.parse(numericPart);
            print(priceValue);
            currentProductPrice = priceValue.toString();
            _connection.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
          },
        );
      },
    );
  }
}


//new rimon
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}