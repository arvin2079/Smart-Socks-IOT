// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppState on _AppState, Store {
  Computed<List<DataPresentationModel>>? _$sensorDataComputed;

  @override
  List<DataPresentationModel> get sensorData => (_$sensorDataComputed ??=
          Computed<List<DataPresentationModel>>(() => super.sensorData,
              name: '_AppState.sensorData'))
      .value;
  Computed<double>? _$sensor0Computed;

  @override
  double get sensor0 => (_$sensor0Computed ??=
          Computed<double>(() => super.sensor0, name: '_AppState.sensor0'))
      .value;
  Computed<double>? _$sensor1Computed;

  @override
  double get sensor1 => (_$sensor1Computed ??=
          Computed<double>(() => super.sensor1, name: '_AppState.sensor1'))
      .value;
  Computed<double>? _$sensor2Computed;

  @override
  double get sensor2 => (_$sensor2Computed ??=
          Computed<double>(() => super.sensor2, name: '_AppState.sensor2'))
      .value;
  Computed<double>? _$sensor3Computed;

  @override
  double get sensor3 => (_$sensor3Computed ??=
          Computed<double>(() => super.sensor3, name: '_AppState.sensor3'))
      .value;
  Computed<double>? _$sensor4Computed;

  @override
  double get sensor4 => (_$sensor4Computed ??=
          Computed<double>(() => super.sensor4, name: '_AppState.sensor4'))
      .value;
  Computed<double>? _$sensor5Computed;

  @override
  double get sensor5 => (_$sensor5Computed ??=
          Computed<double>(() => super.sensor5, name: '_AppState.sensor5'))
      .value;
  Computed<ThemeMode>? _$themeModeComputed;

  @override
  ThemeMode get themeMode =>
      (_$themeModeComputed ??= Computed<ThemeMode>(() => super.themeMode,
              name: '_AppState.themeMode'))
          .value;

  final _$coefsAtom = Atom(name: '_AppState.coefs');

  @override
  ObservableList<double> get coefs {
    _$coefsAtom.reportRead();
    return super.coefs;
  }

  @override
  set coefs(ObservableList<double> value) {
    _$coefsAtom.reportWrite(value, super.coefs, () {
      super.coefs = value;
    });
  }

  final _$biasesAtom = Atom(name: '_AppState.biases');

  @override
  ObservableList<double> get biases {
    _$biasesAtom.reportRead();
    return super.biases;
  }

  @override
  set biases(ObservableList<double> value) {
    _$biasesAtom.reportWrite(value, super.biases, () {
      super.biases = value;
    });
  }

  final _$isLocEnabledAtom = Atom(name: '_AppState.isLocEnabled');

  @override
  bool get isLocEnabled {
    _$isLocEnabledAtom.reportRead();
    return super.isLocEnabled;
  }

  @override
  set isLocEnabled(bool value) {
    _$isLocEnabledAtom.reportWrite(value, super.isLocEnabled, () {
      super.isLocEnabled = value;
    });
  }

  final _$isDarkThemeAtom = Atom(name: '_AppState.isDarkTheme');

  @override
  bool get isDarkTheme {
    _$isDarkThemeAtom.reportRead();
    return super.isDarkTheme;
  }

  @override
  set isDarkTheme(bool value) {
    _$isDarkThemeAtom.reportWrite(value, super.isDarkTheme, () {
      super.isDarkTheme = value;
    });
  }

  final _$messagesAtom = Atom(name: '_AppState.messages');

  @override
  ObservableList<Message> get messages {
    _$messagesAtom.reportRead();
    return super.messages;
  }

  @override
  set messages(ObservableList<Message> value) {
    _$messagesAtom.reportWrite(value, super.messages, () {
      super.messages = value;
    });
  }

  final _$selectedSensorAtom = Atom(name: '_AppState.selectedSensor');

  @override
  int get selectedSensor {
    _$selectedSensorAtom.reportRead();
    return super.selectedSensor;
  }

  @override
  set selectedSensor(int value) {
    _$selectedSensorAtom.reportWrite(value, super.selectedSensor, () {
      super.selectedSensor = value;
    });
  }

  final _$schemeRightFootAtom = Atom(name: '_AppState.schemeRightFoot');

  @override
  bool get schemeRightFoot {
    _$schemeRightFootAtom.reportRead();
    return super.schemeRightFoot;
  }

  @override
  set schemeRightFoot(bool value) {
    _$schemeRightFootAtom.reportWrite(value, super.schemeRightFoot, () {
      super.schemeRightFoot = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_AppState.init');

  @override
  Future<bool> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$setCalibrationParamsAsyncAction =
      AsyncAction('_AppState.setCalibrationParams');

  @override
  Future<void> setCalibrationParams(dynamic index) {
    return _$setCalibrationParamsAsyncAction
        .run(() => super.setCalibrationParams(index));
  }

  final _$checkLocIsOnAsyncAction = AsyncAction('_AppState.checkLocIsOn');

  @override
  Future<void> checkLocIsOn() {
    return _$checkLocIsOnAsyncAction.run(() => super.checkLocIsOn());
  }

  final _$_AppStateActionController = ActionController(name: '_AppState');

  @override
  void switchTheme(bool val) {
    final _$actionInfo =
        _$_AppStateActionController.startAction(name: '_AppState.switchTheme');
    try {
      return super.switchTheme(val);
    } finally {
      _$_AppStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void disposeConnection() {
    final _$actionInfo = _$_AppStateActionController.startAction(
        name: '_AppState.disposeConnection');
    try {
      return super.disposeConnection();
    } finally {
      _$_AppStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
coefs: ${coefs},
biases: ${biases},
isLocEnabled: ${isLocEnabled},
isDarkTheme: ${isDarkTheme},
messages: ${messages},
selectedSensor: ${selectedSensor},
schemeRightFoot: ${schemeRightFoot},
sensorData: ${sensorData},
sensor0: ${sensor0},
sensor1: ${sensor1},
sensor2: ${sensor2},
sensor3: ${sensor3},
sensor4: ${sensor4},
sensor5: ${sensor5},
themeMode: ${themeMode}
    ''';
  }
}
