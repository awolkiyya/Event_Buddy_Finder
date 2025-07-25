class NotificationModel {
  final String title;
  final String body;
  final String? screen;

  NotificationModel({
    required this.title,
    required this.body,
    this.screen,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data) {
    return NotificationModel(
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      screen: data['screen'],
    );
  }
}
