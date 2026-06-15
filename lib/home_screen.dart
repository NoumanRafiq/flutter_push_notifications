import 'package:flutter/material.dart';
import 'package:push_notifications/notification_services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context: context);
    // notificationServices.onTokenRefresh();
    // notificationServices.onBackgroundMessageHandle(context);
    notificationServices.setupInteractedMessage();
    notificationServices.getDeviceToken().then((val){
      print('device token $val');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homescreen'),
      ),
      body: Center(child: Text('Welcome to home screen')),
    );
  }
}
