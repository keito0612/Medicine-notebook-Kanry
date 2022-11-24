class Medicine {
  int? id;
  String? hospitalText;
  String? examinationText;
  String? time;
  String? image;

  Medicine(
      {this.id,
      required this.hospitalText,
      required this.examinationText,
      required this.time,
      required this.image});

  /// Map型に変換
  Map<String, dynamic> fromMap() {
    return {
      'id': id,
      'hospitalText': hospitalText,
      'examinationText': examinationText,
      'time': time,
      'image': image
    };
  }

  /// JSONオブジェクトを代入
  Medicine.toJson(Map json)
      : id = json['id'],
        hospitalText = json['hospitalText'],
        examinationText = json['examinationText'],
        time = json['time'],
        image = json['image'];
}
