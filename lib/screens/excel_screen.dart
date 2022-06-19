import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'login_screen.dart';
import '../shared/authentication.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:charts_flutter/src/text_element.dart' as charts_text;
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_charts/src/chart/axis/axis.dart';
import 'dart:math';
import 'package:excel/excel.dart';
// import '../firebase_options.dart';

class ExcelScreen extends StatefulWidget {
  final List<String?> userList;

  ExcelScreen(this.userList) {
    Firebase.initializeApp();
  }

  // const SimpleTimeSeriesChart();

  @override
  _SimpleTimeSeriesChartState createState() {
    return _SimpleTimeSeriesChartState(userList);
  }
}

class _SimpleTimeSeriesChartState extends State<ExcelScreen> {
  ZoomPanBehavior? zoomPanBehavior = ZoomPanBehavior();
  late String dateString;
  late ChartSeriesController _chartSeriesController;
  late TrackballBehavior _trackballBehavior;
  late CrosshairBehavior _crosshairBehavior;
  late TooltipBehavior _tooltipBehavior;
  late RangeController _rangeController;
  late DateTime dateValue;
  late num assetValue;
  late SfCartesianChart columnChart, lineChart;
  final List<String?> userList;
  late String? email = userList[1];
  DateTime? _startDate = DateTime(2022, 01, 01),
      _endDate = DateTime(2022, 05, 31);
  DateTime? min = DateTime(2022, 01, 01), max = DateTime(2022, 05, 31);
  final DateRangePickerController _controller = DateRangePickerController();
  late DateTime today;
  List<dynamic>? querySnapshot;
  int count = 0;

  // final DateTime min = DateTime(2021, 06, 28),
  //     max = DateTime(2022, 05, 31);
  List<charts.Series<dynamic, DateTime>>? seriesList;
  bool? animate;

  _SimpleTimeSeriesChartState(this.userList);

  /// Creates a [PieChart] with sample data and no transition.
  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    today = DateTime.now();
    _createSampleData().then((data) {
      setState(() {
        querySnapshot = data;
        min = querySnapshot![1];
        max = querySnapshot![2];
        _startDate = min;
        _endDate = max;
        _controller.selectedRange = PickerDateRange(_startDate, _endDate);
        _rangeController = RangeController(start: min, end: max);
        zoomPanBehavior = ZoomPanBehavior(

            /// To enable the pinch zooming as true.
            enablePinching: true,
            zoomMode: ZoomMode.x,
            enablePanning: true,
            enableMouseWheelZooming: true);
        _trackballBehavior = TrackballBehavior(
            // Enables the trackball
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
            tooltipSettings: InteractiveTooltip(format: 'point.y.toInt()'),
            lineType: TrackballLineType.none);
        _crosshairBehavior = CrosshairBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            lineType: CrosshairLineType.vertical);
      });
    });
  }

  // _rangeController = RangeController(
  //     start: min,
  //     end: max);

  @override
  void dispose() {
    // _rangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Authentication auth = Authentication();

    // columnChart = SfCartesianChart(
    //     margin: EdgeInsets.zero,
    //     primaryXAxis: DateTimeAxis(
    //       isVisible: false,
    //       intervalType: DateTimeIntervalType.days,
    //       // minimum: min,
    //       maximum: max,
    //       // rangeController: _rangeController // Setting range controller for the chart axis
    //     ),
    //     primaryYAxis: sf.NumericAxis(isVisible: false),
    //     plotAreaBorderWidth: 0,
    //     series: <ChartSeries<dynamic, DateTime>>[
    //       LineSeries<ChartData, DateTime>(
    //         dataSource: querySnapshot![0],
    //         xValueMapper: (ChartData sales, _) => sales.time as DateTime,
    //         yValueMapper: (ChartData sales, _) => sales.sales,
    //       )
    //     ]
    // );
    void showCrossHair(int index) {
      _crosshairBehavior.showByIndex(index);
    }

    void showTrackball(int index) {
      _trackballBehavior.showByIndex(index);
    }

    if (querySnapshot != null && _startDate != null && _endDate != null) {
      // ChartAxisRendererDetails axisDetails;
      // ZoomAxisRange range;
      // VisibleRange? axisRange;
      lineChart = SfCartesianChart(
        enableAxisAnimation: true,
        // onDataLabelRender: (DataLabelRenderArgs args) {
        //   // count >= 0 ? showTrackball(count + 1) : null;
        //   count > 0 ? showCrossHair(count + 1) : null;
        // },
        trackballBehavior: _trackballBehavior,
        // crosshairBehavior: _crosshairBehavior,
        onTrackballPositionChanging: (args) {
          // Formating the x value using DateFormat to display like the below format
          // MMM dd, YYYY (Nov 1, 2020)
          dateString =
              DateFormat.yMMMd().format(args.chartPointInfo.chartDataPoint!.x);
          // Appended the formatted date string in the trackball tooltip’s label.
          args.chartPointInfo.label = '$dateString \n'
              '${args.chartPointInfo.chartDataPoint!.y.toInt()}';
        },
        onActualRangeChanged: (ActualRangeChangedArgs args) async {
          if (args.axisName == 'primaryXAxis') {
            _chartSeriesController.animate();
            // zoomPanBehavior;
            // if(mounted){
            // setState((){
            //   _startDate = DateTime.fromMicrosecondsSinceEpoch(args.visibleMin);
            //   _endDate = DateTime.fromMicrosecondsSinceEpoch(args.visibleMax);;
            // datePicker(_startDate, _endDate!);
          }
        },
        zoomPanBehavior: ZoomPanBehavior(

            /// To enable the pinch zooming as true.
            enablePinching: true,
            zoomMode: ZoomMode.x,
            enablePanning: true,
            enableMouseWheelZooming: true),
        // onTooltipRender: (TooltipArgs args) {
        //   //Tooltip with formatted DateTime values
        //   List<dynamic>? chartdata = args.dataPoints;
        //   int chartIndex = args.pointIndex!.toInt();
        //   args.header =
        //       DateFormat('d MMM yyyy').format(chartdata![chartIndex].x);
        //   args.text = '${chartdata![chartIndex].y}';
        // },
        primaryXAxis: DateTimeAxis(
          rangePadding: ChartRangePadding.round,
          intervalType: DateTimeIntervalType.days,
          enableAutoIntervalOnZooming: true,
          // minimum: _startDate,
          // maximum: _endDate,
          visibleMinimum: _startDate,
          visibleMaximum: _endDate,
          // rangeController: _rangeController, // Setting range controller for the chart axis
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          isVisible: true,
        ),
        primaryYAxis: sf.NumericAxis(
          interactiveTooltip: InteractiveTooltip(enable: false),
          enableAutoIntervalOnZooming: true,
          // numberFormat: NumberFormat.compact(),
          decimalPlaces: 0,
          rangePadding: ChartRangePadding.round,
          labelPosition: ChartDataLabelPosition.outside,
          labelAlignment: LabelAlignment.end,
          majorTickLines: const MajorTickLines(size: 0),
          axisLine: const AxisLine(color: Colors.transparent),
          anchorRangeToVisiblePoints: true,
        ),
        series: <ChartSeries<dynamic, DateTime>>[
          LineSeries<ChartData, DateTime>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            dataSource: querySnapshot![0],
            animationDuration: 0,
            xValueMapper: (ChartData sales, _) => sales.time as DateTime,
            yValueMapper: (ChartData sales, _) => sales.sales,
          )
        ],
        // tooltipBehavior: _tooltipBehavior,
      );

      return Scaffold(
          appBar: AppBar(
            title: const Text('Binance Profit & Loss'),
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  auth.signOut().then((result) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  });
                },
              )
            ],
          ),
          body: Center(
              // child: SingleChildScrollView(
              //     child: SizedBox(
              //         height: 800,
              child: Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      datePicker(),
                      Expanded(
                          child: Container(
                        child: lineChart,
                      )),
                      // SfRangeSelectorTheme(
                      //     data: SfRangeSelectorThemeData(),
                      //     child: Container(
                      //         margin: c,
                      //         padding: EdgeInsets.zero,
                      //         child: Center(
                      //             child: Padding(
                      //                 padding: const EdgeInsets
                      //                     .fromLTRB(14, 0, 15, 15),
                      //                 child: SfRangeSelector(
                      //                     min: min,
                      //                     max: max,
                      //                     interval: 3,
                      //                     enableDeferredUpdate: true,
                      //                     deferredUpdateDelay: 500,
                      //                     dateFormat: DateFormat.yM(),
                      //                     dateIntervalType: DateIntervalType
                      //                         .months,
                      //                     controller: _rangeController,
                      //                     showTicks: true,
                      //                     showLabels: true,
                      //                     dragMode: SliderDragMode
                      //                         .both,
                      //                     onChanged: (
                      //                         SfRangeValues values) {},
                      //                     child: Container(
                      //                       height: 75,
                      //                       padding: EdgeInsets.zero,
                      //                       margin: EdgeInsets.zero,
                      //                       child: columnChart,)))))),
                    ],
                  )))));
      // )
      //   );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Binance Profit & Loss'),
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  auth.signOut().then((result) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  });
                },
              )
            ],
          ),
          body: Center(
              // child: SingleChildScrollView(
              //     child: SizedBox(
              //         height: 800,
              child: Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Center(
                      child: Column(children: <Widget>[
                    datePicker(),
                  ])))));
      // return const CircularProgressIndicator();
    }
  }

  Widget datePicker() {
    if (_startDate != null && _endDate != null) {
      return MaterialButton(
          child: Container(
              child: Row(children: <Widget>[
            Expanded(
                child: Text('${DateFormat('dd MMM, yyyy').format(_startDate!)}'
                    ' - '
                    '${DateFormat('dd MMM, yyyy').format(_endDate!)}')),
            const Icon(Icons.calendar_month)
          ])),
          onPressed: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text(''),
                      content: Container(
                          width: 350,
                          height: 350,
                          child: Column(children: <Widget>[
                            getDateRangePicker(),
                            MaterialButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _chartSeriesController.animate();
                                  // if (zoomPanBehavior != null) {
                                  //   zoomPanBehavior!.zoomByFactor(0.5);}
                                })
                          ])));
                });
          });
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget getDateRangePicker() {
    return Container(
        height: 250,
        child: Card(
            child: SfDateRangePicker(
          controller: _controller,
          view: DateRangePickerView.month,
          selectionMode: DateRangePickerSelectionMode.range,
          onSelectionChanged: selectionChanged,
        )));
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _startDate = args.value.startDate;
      _endDate = args.value.endDate;
      // _rangeController.start =_startDate;
      // _rangeController.end =_endDate;
    });
  }

  /// Create one series with sample hard coded data.
  Future<List<dynamic>> _createSampleData() async {
    DateTime dateValue;
    num assetValue;
    List<ChartData>? data = [];
    var csvTable;
    // var myData = File('assets/binance.csv').openRead();
    // loadAsset().then((String myData) {
    // final csvTable = await myData.transform(utf8.decoder).transform(new CsvToListConverter()).toList();
    //
    // String myData = await rootBundle.loadString("assets/binance.csv");
    // List<List<dynamic>> csvTable = const CsvToListConverter().convert(myData);
    //
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('binance')
        .child('/Binance.xlsx');
    Uint8List? myref = await ref.getData();

    // ByteData mydata = await rootBundle.load("assets/Binance.xlsx");
    // var bytes =
    //     mydata.buffer.asUint8List(mydata.offsetInBytes, mydata.lengthInBytes);
    // var csvTable = Excel.decodeBytes(bytes);
    if (myref != null) {
      csvTable = Excel.decodeBytes(myref!);
    }
    // else {
    //   print('firebase storage get failed');
    //   csvTable = Excel.decodeBytes(bytes);
    // }

    List<dynamic> dataList;
    // List<double> assetlist = [];
    // if (email != null) {
    for (int i = 1; i < csvTable.tables[email]!.maxRows; i++) {
      dataList = csvTable.tables[email]!.rows[i];

      dateValue = DateTime.parse(dataList[0]);
      // print(csvTable[i][2]);
      if (dataList[2]?.runtimeType == String) {
        assetValue = NumberFormat().parse(dataList[2]!.toString()) as num;
      } else {
        assetValue = dataList[2] as num;
      }
      // print(assetValue);
      data.add(ChartData(dateValue, assetValue));
    }
    int maxRow = csvTable.tables[email]!.maxRows;
    DateTime min =
        DateTime.parse(csvTable.tables[email]!.rows[maxRow - 1][0]);
    DateTime max = DateTime.parse(csvTable.tables[email]!.rows[1][0]);
    return [data, min, max];
  }
}

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  static String value = "";

  @override
  void paint(ChartCanvas canvas, Rectangle<num> bounds,
      {List<int>? dashPattern,
      Color? fillColor,
      FillPatternType? fillPattern,
      Color? strokeColor,
      double? strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        fillPattern: fillPattern,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
        Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 10,
            bounds.height + 10),
        fill: Color.white);
    var textStyle = style.TextStyle();
    textStyle.color = Color.black;
    textStyle.fontSize = 15;
    canvas.drawText(charts_text.TextElement(value, style: textStyle),
        (bounds.left).round(), (bounds.top - 28).round());
  }
}

/// Sample time series data type.
class ChartData {
  final DateTime time;
  final num sales;

  ChartData(this.time, this.sales);
}
