import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../services/notification_service.dart';

import 'my_order_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<Map<String, dynamic>> notificationArr = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      notificationArr = NotificationService.getNotificationHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset("assets/img/btn_back.png",
                          width: 20, height: 20),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyOrderView()));
                      },
                      icon: Image.asset(
                        "assets/img/shopping_cart.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),
              if (notificationArr.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(color: TColor.secondaryText),
                    ),
                  ),
                )
              else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: notificationArr.length,
                separatorBuilder: ((context, index) => Divider(
                  indent: 25,
                  endIndent: 25,
                      color: TColor.secondaryText.withOpacity(0.4),
                      height: 1,
                    )),
                itemBuilder: ((context, index) {
                  var n = notificationArr[index];
                  return NotificationTile(
                    notification: n,
                    onTap: () {
                      NotificationService.markAsRead(index);
                      _load();
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
