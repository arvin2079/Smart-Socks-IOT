import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_socks_iot/models/message_model.dart';

part 'app_state.g.dart';

class AppState extends _AppState with _$AppState {}

abstract class _AppState with Store {

  /// constant variables, from each variables name it is clear what are they for
  final String DATA_DELIMETER = ',';
  final double SENSORS_DEFAULT_VALUE = -1;
  final int SENSORS_NO = 6;

  /// sensors value calculation parameters
  final double voltageDividerR1 = 10000;
  final double BValue = 3470;
  final double R1 = 10000;
  final double T1 = 298.15;

  /// logarithm with base 10
  double log10(num x) => math.log(x) / math.log(10);

  /// function to calculate temperature using parameters and sensors data
  double calcTemp(double tempMean) {
    double R2 = (voltageDividerR1*tempMean)/(4096-tempMean);
    double a = 1/T1;
    double b = log10(R1/R2);
    double c = b / math.log10e;
    double d = c / BValue ;
    double T2 = 1 / (a - d);
    double ret = T2 - 273.15;
    return ret;
  }

  /// calibration parameters
  @observable
  ObservableList<double> coefs = ObservableList<double>.of(List<double>.filled(6, 1));

  @observable
  ObservableList<double> biases = ObservableList<double>.of(List<double>.filled(6, 0));


  @observable
  bool isLocEnabled = true;

  @observable
  bool isDarkTheme = ThemeMode.system == ThemeMode.dark;

  @observable
  ObservableList<Message> messages = ObservableList<Message>();

  @observable
  int selectedSensor = 0;

  @observable
  bool schemeRightFoot = true;


  @computed
  /// return last 30 record of incoming data from desired sensor to be shown and
  /// plotted on line chart
  List<DataPresentationModel> get sensorData {
    if (selectedSensor >= SENSORS_NO || selectedSensor < 0) return [];

    int recordsNo = 30;
    List<Message> selectedMessages = List.from(messages);
    selectedMessages.removeWhere((element) => element.whom == 0);

    if (selectedMessages.length >= recordsNo) {
      selectedMessages.removeRange(0, messages.length - recordsNo);
    }

    List<DataPresentationModel> convertedMessages = <DataPresentationModel>[];
    for (final message in selectedMessages) {
      String textValue = message.text.replaceAll('Value=', '').replaceAll(';', '');
      double val = calcTemp(double.parse(textValue.split(DATA_DELIMETER)[selectedSensor].trim())) * coefs[selectedSensor] + biases[selectedSensor];
      convertedMessages.add(DataPresentationModel(message.time, val));
    }

    return convertedMessages;
  }

  /// these getter functions bellow are meant to extract desired sensor value out
  /// of whole data gained from blue deviced and stacked in messages buffer. also
  /// they are responsible for calibration.

  @computed
  double get sensor0 {
    if (messages.isEmpty) return SENSORS_DEFAULT_VALUE;
    String lastMsg = messages.lastWhere((element) => element.whom == 1).text;
    String textValue = lastMsg.replaceAll('Value=', '').replaceAll(';', '');
    return calcTemp(double.parse(textValue.split(DATA_DELIMETER)[0].trim())) * coefs[0] + biases[0];
  }

  @computed
  double get sensor1 {
    if (messages.isEmpty) return SENSORS_DEFAULT_VALUE;
    String lastMsg = messages.lastWhere((element) => element.whom == 1).text;
    String textValue = lastMsg.replaceAll('Value=', '').replaceAll(';', '');
    return calcTemp(double.parse(textValue.split(DATA_DELIMETER)[1].trim())) * coefs[1] + biases[1];
  }

  @computed
  double get sensor2 {
    if (messages.isEmpty) return SENSORS_DEFAULT_VALUE;
    String lastMsg = messages.lastWhere((element) => element.whom == 1).text;
    String textValue = lastMsg.replaceAll('Value=', '').replaceAll(';', '');
    return calcTemp(double.parse(textValue.split(DATA_DELIMETER)[2].trim())) * coefs[2] + biases[2];
  }

  @computed
  double get sensor3 {
    if (messages.isEmpty) return SENSORS_DEFAULT_VALUE;
    String lastMsg = messages.lastWhere((element) => element.whom == 1).text;
    String textValue = lastMsg.replaceAll('Value=', '').replaceAll(';', '');
    return calcTemp(double.parse(textValue.split(DATA_DELIMETER)[3].trim())) * coefs[3] + biases[3];
  }

  @computed
  double get sensor4 {
    if (messages.isEmpty) return SENSORS_DEFAULT_VALUE;
    String lastMsg = messages.lastWhere((element) => element.whom == 1).text;
    String textValue = lastMsg.replaceAll('Value=', '').replaceAll(';', '');
    return calcTemp(double.parse(textValue.split(DATA_DELIMETER)[4].trim())) * coefs[4] + biases[4];
  }

  @computed
  double get sensor5 {
    if (messages.isEmpty) return SENSORS_DEFAULT_VALUE;
    String lastMsg = messages.lastWhere((element) => element.whom == 1).text;
    String textValue = lastMsg.replaceAll('Value=', '').replaceAll(';', '');
    return calcTemp(double.parse(textValue.split(DATA_DELIMETER)[5].trim())) * coefs[5] + biases[5];
  }



  @computed
  ThemeMode get themeMode {
    return isDarkTheme ? ThemeMode.dark : ThemeMode.light;
  }

  @action
  Future<bool> init() async {
    /// Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    coefs[0] = prefs.getDouble('sen0coef') ?? 1;
    coefs[1] = prefs.getDouble('sen1coef') ?? 1;
    coefs[2] = prefs.getDouble('sen2coef') ?? 1;
    coefs[3] = prefs.getDouble('sen3coef') ?? 1;
    coefs[4] = prefs.getDouble('sen4coef') ?? 1;
    coefs[5] = prefs.getDouble('sen5coef') ?? 1;

    biases[0] = prefs.getDouble('sen0bias') ?? 0;
    biases[1] = prefs.getDouble('sen1bias') ?? 0;
    biases[2] = prefs.getDouble('sen2bias') ?? 0;
    biases[3] = prefs.getDouble('sen3bias') ?? 0;
    biases[4] = prefs.getDouble('sen4bias') ?? 0;
    biases[5] = prefs.getDouble('sen5bias') ?? 0;
    print('KKKKKK');
    print(coefs);
    print(biases);
    print('kkkkkk');
    return true;
  }

  @action
  Future<void> setCalibrationParams(index) async {
    /// Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('sen' + index.toString() + 'coef', coefs[index]);
    await prefs.setDouble('sen' + index.toString() + 'bias', biases[index]);
  }

  @action
  /// setter function to switch application theme as the it's name suggest too.
  void switchTheme(bool val) {
    isDarkTheme = val;
  }

  @action
  /// check location permission
  Future<void> checkLocIsOn() async {
    isLocEnabled = await Permission.locationWhenInUse.serviceStatus.isEnabled;
  }

  @action
  /// dispose the buffer and reset every neccessary parameters like selectedSensor
  /// to the default value.
  void disposeConnection() {
    messages.clear();
    selectedSensor = 0;
    schemeRightFoot = true;
  }
}


/// to share the viewmodel or statemodel among the application we are using singleton
/// architecture, and here is the instance declared as our class singleton:
AppState _singleton = AppState();

AppState get singletonInstance {
  return _singleton;
}
