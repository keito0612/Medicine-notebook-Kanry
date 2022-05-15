class Medicine {
  int? id;
  String? hospitalText;
  String? examinationText;
  String? time;
  String? image;

  Medicine(
      {this.id,
      this.hospitalText,
      this.examinationText,
      this.time,
      this.image});

  /// Map型に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hospitalText': hospitalText,
      'examinationText': examinationText,
      'time': time,
      'image': image
    };
  }

  /// JSONオブジェクトを代入
  Medicine.fromMap(Map json)
      : id = json['id'],
        hospitalText = json['hospitalText'],
        examinationText = json['examinationText'],
        time = json['time'],
        image = json['image'];
}
