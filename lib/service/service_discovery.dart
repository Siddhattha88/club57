import 'package:flutter/cupertino.dart';
import 'package:multicast_dns/multicast_dns.dart';
typedef ServiceDiscoveredCallback = void Function(String hostname, int port);

class ServiceDiscovery extends ChangeNotifier {
  final MDnsClient _mdnsClient = MDnsClient();
  List<Map<String, dynamic>> foundServices = [];

  ServiceDiscovery();

  Future<void> startDiscovery(String serviceType) async {
    await _mdnsClient.start();

    final PtrResourceRecord ptr = await _mdnsClient.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer(serviceType),
    ).first;

    await for (final SrvResourceRecord srv in _mdnsClient.lookup<SrvResourceRecord>(
      ResourceRecordQuery.service(ptr.domainName),
    )) {
      foundServices.add({'host': srv.target, 'port': srv.port});
      print('Found service: Host=${srv.target}, Port=${srv.port}');
      notifyListeners();
    }
  }

  Future<void> stopDiscovery() async {
    _mdnsClient.stop();
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter_mdns_plugin/flutter_mdns_plugin.dart';
//
// class ServiceDiscovery extends ChangeNotifier {
//   late FlutterMdnsPlugin _flutterMdnsPlugin;
//   List<ServiceInfo> foundServices = [];
//
//   ServiceDiscovery() {
//     _flutterMdnsPlugin = FlutterMdnsPlugin(
//         discoveryCallbacks: DiscoveryCallbacks(
//             onDiscoveryStarted: () => {},
//             onDiscoveryStopped: () => {},
//             onDiscovered: (ServiceInfo serviceInfo) => {},
//             onResolved: (ServiceInfo serviceInfo) {
//               print('found device ${serviceInfo.toString()}');
//               foundServices.add(serviceInfo);
//               notifyListeners();
//             }));
//   }
//
//   startDiscovery() {
//     _flutterMdnsPlugin.startDiscovery('_googlecast._tcp');
//   }
//
//   stopDiscovery() {
//     _flutterMdnsPlugin.stopDiscovery();
//   }
// }
