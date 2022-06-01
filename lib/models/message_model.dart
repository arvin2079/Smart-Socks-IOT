class Message {
  int whom;
  String text;
  DateTime time;

  Message(this.whom, this.text, this.time);

  @override
  String toString() {
    return 'id:$whom, message:${text.trim()}, datetime:$time';
  }
}


class DataPresentationModel {
  double sensorValue;
  DateTime time;

  DataPresentationModel(this.time, this.sensorValue);
}