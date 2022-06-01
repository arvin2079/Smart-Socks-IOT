import 'dart:convert';
import 'dart:typed_data';
import 'dart:core';
import 'dart:io';
import 'package:intl/intl.dart' as intl;

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_socks_iot/models/message_model.dart';
import 'package:smart_socks_iot/states/app_state.dart' as appState;
import 'package:syncfusion_flutter_charts/charts.dart';

// for mock and test purpose
import 'dart:math' as math;

/*
* presentation Page is the page which  is meant to  demonstrate  sensors data in
* varied forms in tabular UI:
* 
* (1) one  way  is to show as pure data received  from intended bluetooth device
* (first tab).
* (2) another way of getting better insight  out of sensors data is to plot them 
* on a simple line chart (in second tab).
* (3) third tab is a foot scheme which shows  which  sensor placed where on sole
* of the foot.
* */

class PresentationPage extends StatefulWidget {
  final BluetoothDevice server;

  const PresentationPage({required this.server});

  @override
  _PresentationPage createState() => _PresentationPage();
}

class _PresentationPage extends State<PresentationPage>
    with TickerProviderStateMixin {
  static const clientID = 0;
  BluetoothConnection? connection;

  String _messageBuffer = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  late TabController _tabController;

  late List<TextEditingController> coefsTFController;
  late List<TextEditingController> biasesTFController;

  bool isConnecting = true;

  bool mockMood = false;

  bool get isConnected => (connection?.isConnected ?? false) | mockMood;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    if (!mockMood) {
      BluetoothConnection.toAddress(widget.server.address).then((_connection) {
        connection = _connection;
        setState(() {
          isConnecting = false;
          isDisconnecting = false;
        });

        connection!.input!.listen(_onDataReceived).onDone(() {
          /// Example: Detect which side closed the connection
          /// There should be `isDisconnecting` flag to show are we are (locally)
          /// in middle of disconnecting process, should be set before calling
          /// `dispose`, `finish` or `close`, which all causes to disconnect.
          /// If we except the disconnection, `onDone` should be fired as result.
          /// If we didn't except this (no flag set), it means closing by remote.
          if (mounted) {
            setState(() {});
          }
        });
      }).catchError((error) {
        // print('Cannot connect, exception occured');
        // print(error);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (mockMood) {
      _generate_message_mock(context);
    }
  }

  @override
  void dispose() {
    /// Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
      appState.singletonInstance.disposeConnection();
    }
    for (TextEditingController cont in coefsTFController) {
      cont.dispose();
    }
    for (TextEditingController cont in biasesTFController) {
      cont.dispose();
    }
    textEditingController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Iterable<Widget> get _generate_message sync* {
    for (final _message in appState.singletonInstance.messages) {
      yield Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: const TextStyle(color: Colors.white)),
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
      if (_tabController.index == 0) {
        try {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut);
        } catch (e) {
          /// DO nothing just ignore the first error
          // print('ERROR IN listScrollController.animateTo line 139');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      appBar: AppBar(
        title: (isConnecting & !mockMood
            ? const Text('Connecting...')
            : isConnected
                ? Text(serverName)
                : Text('Chat log' + serverName)),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              if (appState.singletonInstance.messages.isNotEmpty) {
                String path = await _fileExporting();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Text file exported into $path')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('no content available yet to be exported!')));
              }
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Export'),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.multiple_stop)),
            Tab(icon: Icon(Icons.bar_chart)),
            Tab(child: Text('Scheme')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConversationTab(),
          _buildChartTab(),
          _buildShcemeTab(),
        ],
      ),
    );
  }

  Widget _buildShcemeTab() {
    double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _drawFootScheme(screenWidth * .6),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hint: sen1 for example refers to value for sensor number one which is placed on the toe.\n\n',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          createDivider('Calibration'),
          calibrationSection(context, 'sensor1', 0),
          calibrationSection(context, 'sensor2', 1),
          calibrationSection(context, 'sensor3', 2),
          calibrationSection(context, 'sensor4', 3),
          calibrationSection(context, 'sensor5', 4),
          calibrationSection(context, 'sensor6', 5),
          const SizedBox(height: 20),
          createDivider('Select foot'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            child: Observer(
              builder: (context) => DropdownButton<bool>(
                isExpanded: true,
                underline: Container(),
                value: appState.singletonInstance.schemeRightFoot,
                items: const [
                  DropdownMenuItem<bool>(
                    value: true,
                    child: Text('Right Foot'),
                  ),
                  DropdownMenuItem<bool>(
                    value: false,
                    child: Text('Left Foot'),
                  )
                ],
                onChanged: (value) {
                  appState.singletonInstance.schemeRightFoot =
                      value ?? appState.singletonInstance.schemeRightFoot;
                },
              ),
            ),
          ),
          Container(
            width: screenWidth,
            padding: const EdgeInsets.all(8),
            child: Observer(
              builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Scheme Detail',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(
                      'as you can see above, 6 sensors mapped to the 6 portion of the sole of the intended foot where each sensor value in real time is showing below:\n'),
                  Text(
                      'Sen1:     ${appState.singletonInstance.sensor0 == -1 ? 'waiting..' : appState.singletonInstance.sensor0}'),
                  const Divider(),
                  Text(
                      'Sen2:     ${appState.singletonInstance.sensor1 == -1 ? 'waiting..' : appState.singletonInstance.sensor1}'),
                  const Divider(),
                  Text(
                      'Sen3:     ${appState.singletonInstance.sensor2 == -1 ? 'waiting..' : appState.singletonInstance.sensor2}'),
                  const Divider(),
                  Text(
                      'Sen4:     ${appState.singletonInstance.sensor3 == -1 ? 'waiting..' : appState.singletonInstance.sensor3}'),
                  const Divider(),
                  Text(
                      'Sen5:     ${appState.singletonInstance.sensor4 == -1 ? 'waiting..' : appState.singletonInstance.sensor4}'),
                  const Divider(),
                  Text(
                      'Sen6:     ${appState.singletonInstance.sensor5 == -1 ? 'waiting..' : appState.singletonInstance.sensor5}'),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget calibrationSection(context, sensorName, index) {
    return FutureBuilder(
      future: appState.singletonInstance.init(),
      builder: (context, snapshot) {
        coefsTFController = List<TextEditingController>.generate(
          6,
          (index) => TextEditingController(
            text: appState.singletonInstance.coefs[index].toString(),
          ),
        );
        biasesTFController = List<TextEditingController>.generate(
          6,
          (index) => TextEditingController(
            text: appState.singletonInstance.biases[index].toString(),
          ),
        );
        return snapshot.hasData
            ? Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10, top: 1, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Observer(
                      builder: (_) {
                        // for (int i=0 ; i<coefsTFController.length ; i++) {
                        //   coefsTFController[i].text = appState.singletonInstance.coefs[i].toString();
                        // }
                        // for (int i=0 ; i<biasesTFController.length ; i++) {
                        //   biasesTFController[i].text = appState.singletonInstance.biases[i].toString();
                        // }
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Coef'),
                                  TextField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: false),
                                    onChanged: (val) async {
                                      appState.singletonInstance.coefs[index] =
                                          double.parse(val);
                                      await appState.singletonInstance
                                          .setCalibrationParams(index);
                                    },
                                    onEditingComplete: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    controller: coefsTFController[index],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Bias'),
                                  TextField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: false),
                                    controller: biasesTFController[index],
                                    onChanged: (val) async {
                                      appState.singletonInstance.biases[index] =
                                          double.parse(val);
                                      await appState.singletonInstance
                                          .setCalibrationParams(index);
                                    },
                                    onEditingComplete: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox();
      },
    );
  }

  Padding createDivider(title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Text(title, textAlign: TextAlign.left),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 5),
              height: 1,
              color: Colors.grey[300],
            ),
          )
        ],
      ),
    );
  }

  Widget _drawFootScheme(double width) {
    width = (width > 250 ? 250 : width);
    return Observer(
      builder: (_) => SizedBox(
        width: width,
        height: width * 2.5,
        // color: Colors.red,
        child: Stack(
          alignment: Alignment.center,
          children: [
            appState.singletonInstance.schemeRightFoot
                ? Image.asset('assets/images/right-sole-foot.png')
                : Image.asset('assets/images/left-sole-foot.png'),
            Positioned(
              top: width * 2.5 * .07,
              left: appState.singletonInstance.schemeRightFoot
                  ? width * .06
                  : null,
              right: !appState.singletonInstance.schemeRightFoot
                  ? width * .06
                  : null,
              child: _schemeDataPoint(
                  appState.singletonInstance.sensor0 == -1
                      ? '...'
                      : appState.singletonInstance.sensor0.toStringAsFixed(1),
                  1,
                  width * .19),
            ),
            Positioned(
              top: width * 2.5 * .26,
              left: appState.singletonInstance.schemeRightFoot
                  ? width * .09
                  : null,
              right: !appState.singletonInstance.schemeRightFoot
                  ? width * .09
                  : null,
              child: _schemeDataPoint(
                  appState.singletonInstance.sensor1 == -1
                      ? '...'
                      : appState.singletonInstance.sensor1.toStringAsFixed(1),
                  2,
                  width * .25),
            ),
            Positioned(
              top: width * 2.5 * .27,
              left: appState.singletonInstance.schemeRightFoot
                  ? width * .38
                  : null,
              right: !appState.singletonInstance.schemeRightFoot
                  ? width * .38
                  : null,
              child: _schemeDataPoint(
                  appState.singletonInstance.sensor2 == -1
                      ? '...'
                      : appState.singletonInstance.sensor2.toStringAsFixed(1),
                  3,
                  width * .25),
            ),
            Positioned(
              top: width * 2.5 * .35,
              left: appState.singletonInstance.schemeRightFoot
                  ? width * .64
                  : null,
              right: !appState.singletonInstance.schemeRightFoot
                  ? width * .64
                  : null,
              child: _schemeDataPoint(
                  appState.singletonInstance.sensor3 == -1
                      ? '...'
                      : appState.singletonInstance.sensor3.toStringAsFixed(1),
                  4,
                  width * .25),
            ),
            Positioned(
              top: width * 2.5 * .5,
              left: appState.singletonInstance.schemeRightFoot
                  ? width * .3
                  : null,
              right: !appState.singletonInstance.schemeRightFoot
                  ? width * .3
                  : null,
              child: _schemeDataPoint(
                  appState.singletonInstance.sensor4 == -1
                      ? '...'
                      : appState.singletonInstance.sensor4.toStringAsFixed(1),
                  5,
                  width * .4),
            ),
            Positioned(
              top: width * 2.5 * .78,
              left: appState.singletonInstance.schemeRightFoot
                  ? width * .3
                  : null,
              right: !appState.singletonInstance.schemeRightFoot
                  ? width * .3
                  : null,
              child: _schemeDataPoint(
                  appState.singletonInstance.sensor5 == -1
                      ? '...'
                      : appState.singletonInstance.sensor5.toStringAsFixed(1),
                  6,
                  width * .4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _schemeDataPoint(String value, int sensorNo, double width) {
    return Column(
      children: [
        Text('sen' + sensorNo.toString(),
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: Colors.black87)),
        Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            color: const Color(0xF5D9F0FF),
            border: Border.all(color: Colors.blue),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  /// build first tab which is meant to demonstrate the incoming data and provide
  /// the possibility of sending data to the bluetooth device too (mutual-communication)
  Widget _buildConversationTab() {
    return Observer(
      builder: (context) => Column(
        children: <Widget>[
          Flexible(
            child: ListView(
                padding: const EdgeInsets.all(12.0),
                controller: listScrollController,
                children: _generate_message.toList()),
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(left: 16.0),
                  child: TextField(
                    style: const TextStyle(fontSize: 15.0),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: isConnecting && !mockMood
                          ? 'Wait until connected...'
                          : isConnected || mockMood
                              ? 'Type your message...'
                              : 'Chat got disconnected',
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                    enabled: isConnected || mockMood,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isConnected
                        ? () => _sendMessage(textEditingController.text)
                        : null),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// build second tab which contain line chart.
  Widget _buildChartTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Observer(
              builder: (_) {
                return SfCartesianChart(
                  title: ChartTitle(
                      text:
                          'Sensor ${appState.singletonInstance.selectedSensor + 1} fluctuations diagram'),
                  primaryXAxis: DateTimeAxis(
                    dateFormat: intl.DateFormat('hh:mm:ss'),
                    // rangePadding: ChartRangePadding.additional,
                    // interval: 5,
                  ),
                  series: <ChartSeries>[
                    LineSeries<DataPresentationModel, DateTime>(
                      dataSource: appState.singletonInstance.sensorData,
                      xValueMapper: (DataPresentationModel data, _) =>
                          data.time,
                      yValueMapper: (DataPresentationModel data, _) =>
                          data.sensorValue,
                      animationDuration: 0,
                    ),
                  ],
                );
              },
            ),
            createDivider('Select sensor'),
            Observer(
              builder: (context) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: Container(),
                  value: appState.singletonInstance.selectedSensor.toString(),
                  items: List.generate(
                          appState.singletonInstance.SENSORS_NO, (i) => i)
                      .map((int value) {
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text('Sensor ${value + 1}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    int intValue = int.parse(value!.trim());
                    if (intValue != appState.singletonInstance.selectedSensor) {
                      appState.singletonInstance.selectedSensor = intValue;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            createDivider('Calibration'),
            calibrationSection(context, 'sensor1', 0),
            calibrationSection(context, 'sensor2', 1),
            calibrationSection(context, 'sensor3', 2),
            calibrationSection(context, 'sensor4', 3),
            calibrationSection(context, 'sensor5', 4),
            calibrationSection(context, 'sensor6', 5),
          ],
        ),
      ),
    );
  }

  // Iterable<Widget> get _getSensorsChoices sync* {
  //   for (int i = 0; i < appState.singletonInstance.SENSORS_NO; i++) {
  //     yield Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 5),
  //         child: ElevatedButton(
  //           child: Text('Sensor $i'),
  //           onPressed: appState.singletonInstance.selectedSensor != i
  //               ? () {
  //                   appState.singletonInstance.selectedSensor = i;
  //                 }
  //               : null,
  //         ));
  //   }
  // }

  /// check if a permission is provided by the user or not, if not request it.
  /// and wait till the request is responded.
  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      return await permission.request() == PermissionStatus.granted;
    }
  }

  /// export a file out of every records of data gained from blue device from the
  /// time communication maintained till now in .txt format in  BTExports folder
  /// in android root directory.
  Future<String> _fileExporting() async {
    // if (await _requestPermission(Permission.storage) &&
    //     await _requestPermission(Permission.accessMediaLocation) &&
    //     await _requestPermission(Permission.manageExternalStorage))
    //   print('permission granted');
    await _requestPermission(Permission.storage);
    await _requestPermission(Permission.accessMediaLocation);
    await _requestPermission(Permission.manageExternalStorage);

    Directory? directory = await getExternalStorageDirectory();
    String newPath = "";
    List<String> paths = directory!.path.split("/");
    for (int x = 1; x < paths.length; x++) {
      String folder = paths[x];
      if (folder != "Android") {
        newPath += "/" + folder;
      } else {
        break;
      }
    }

    newPath = newPath + "/BTExports";
    directory = Directory(newPath);

    print(directory);
    if (!await directory.exists()) await directory.create(recursive: true);
    DateTime now = DateTime.now();
    String messageTime = now.day.toString() +
        '-' +
        now.month.toString() +
        '-' +
        now.year.toString() +
        '(' +
        now.hour.toString() +
        '-' +
        now.minute.toString() +
        '-' +
        now.second.toString() +
        ')';
    File file = File(directory.path + "/$messageTime.txt");
    file.create();
    file.writeAsString(appState.singletonInstance.messages.join('\n'));
    return file.path;
  }

  /// the method that is called whenever data gained from blue device.
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        appState.singletonInstance.messages.add(
          Message(
              1,
              backspacesCounter > 0
                  ? _messageBuffer.substring(
                      0, _messageBuffer.length - backspacesCounter)
                  : _messageBuffer + dataString.substring(0, index),
              DateTime.now()),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  /// method which is used to send data out to the blue device
  void _sendMessage(String text) async {
    if (mockMood) {
      text = text.trim();
      textEditingController.clear();
      if (text.isNotEmpty) {
        appState.singletonInstance.messages
            .add(Message(0, text, DateTime.now()));
      }
    } else {
      text = text.trim();
      textEditingController.clear();

      if (text.isNotEmpty) {
        try {
          connection!.output
              .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
          await connection!.output.allSent;

          appState.singletonInstance.messages
              .add(Message(clientID, text, DateTime.now()));
        } catch (e) {
          // Ignore error, but notify state
          setState(() {});
        } finally {
          try {
            Future.delayed(const Duration(milliseconds: 333)).then((_) {
              listScrollController.animateTo(
                  listScrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 333),
                  curve: Curves.easeOut);
            });
          } catch (e) {
            // Do nothing just ignore the first error
            // print('ERROR IN listScrollController.animateTo line 671');
          }
        }
      }
    }
  }
}

/// nothing just a mock message generator for testing purposes, it will generate
/// messages every 1 second if mockMood is TRUE.
Future<void> _generate_message_mock(BuildContext context) async {
  int sensorsNo = 6;
  double minValue = 1390;
  double maxValue = 1430;

  math.Random _random = math.Random();

  List<String> sensorsValue = List.filled(sensorsNo, '');

  while (true) {
    await Future.delayed(Duration(seconds: 1));

    for (int i = 0; i < sensorsValue.length; i++) {
      sensorsValue[i] =
          (minValue + _random.nextDouble() * (maxValue - minValue))
              .toStringAsFixed(3);
    }

    Message msg =
        Message(1, 'Value=' + sensorsValue.join(', ') + ';', DateTime.now());
    appState.singletonInstance.messages.add(msg);
    print(msg);
  }
}
