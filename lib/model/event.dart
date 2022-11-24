class Event {
  int? id;
  int? notificationId;
  String? titleText;
  String? timeText;
  String? memoText;
  int? isOn;
  String? notificationTime;

  Event(
      {this.id,
      required this.notificationId,
      required this.titleText,
      required this.timeText,
      required this.memoText,
      required this.isOn,
      required this.notificationTime});

  /// Map型に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notificationId': notificationId,
      'titleText': titleText,
      'timeText': timeText,
      'memoText': memoText,
      'isOn': isOn,
      'notificationTime': notificationTime
    };
  }

  /// JSONオブジェクトを代入
  Event.fromMap(Map json)
      : id = json['id'],
        notificationId = json['notificationId'],
        titleText = json['titleText'],
        timeText = json['timeText'],
        memoText = json['memoText'],
        isOn = json['isOn'],
        notificationTime = json['notificationTime'];
}
