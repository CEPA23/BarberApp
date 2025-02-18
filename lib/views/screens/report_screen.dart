import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';

import '../../services/report_service.dart';

/// Modelo de datos que representa una serie temporal de ventas.
class TimeSeriesSales {
  final DateTime fecha;
  final int cantidad;

  TimeSeriesSales(this.fecha, this.cantidad);
}

/// Formato de fecha para mostrar en el gráfico de series temporales.
final _monthDayFormat = DateFormat('MM-dd');

/// Datos de ejemplo para la serie temporal.
final timeSeriesSales = [
  TimeSeriesSales(DateTime(2017, 9, 19), 5),
  TimeSeriesSales(DateTime(2017, 9, 26), 25),
  TimeSeriesSales(DateTime(2017, 10, 3), 100),
  TimeSeriesSales(DateTime(2017, 10, 10), 75),
];

/// Pantalla de reportes que muestra datos visuales sobre servicios solicitados y citas atendidas.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  /// Lista de servicios solicitados en el mes.
  List<Map<String, dynamic>> mapaServicios = [];

  /// Lista de citas atendidas en el mes.
  List<dynamic> cantidadCitas = [];

  @override
  void initState() {
    super.initState();
    getCountServices();
    getCountCitas();
  }

  /// Obtiene la cantidad de servicios solicitados del servicio de reportes.
  Future<void> getCountServices() async {
    List<Map<String, dynamic>> count = await report_service().getServiciosSolicitadosMensuales();
    setState(() {
      try {
        mapaServicios = count;
        print('LONGITUD ARRAY CITAS ATENDIDAS: ${mapaServicios.length}');
      } catch (e) {
        print('Error al obtener servicios');
      }
    });
  }

  /// Obtiene la cantidad de citas atendidas del servicio de reportes.
  Future<void> getCountCitas() async {
    List<TimeSeriesSales> count = await report_service().getCitasAtendidas();
    setState(() {
      try {
        cantidadCitas = count;
        print('LONGITUD ARRAY CITAS ATENDIDAS: ${cantidadCitas.length}');
      } catch (e) {
        print('Error al obtener citas');
      }
    });
  }

  /// Lista de nombres de meses para mostrar en los gráficos.
  List<String> meses = [
    'Diciembre', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo',
    'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
        title: const Text(
          'Reportes',
          style: TextStyle(
            color: Color.fromRGBO(126, 217, 87, 1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(top: 10)),
              _buildChartContainer(
                title: 'Servicios más solicitados en el mes de ${meses[DateTime.now().month - 1]}',
                chart: _buildBarChart(),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              _buildChartContainer(
                title: 'Registro de citas atendidas últimamente',
                chart: _buildLineChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el contenedor de gráficos con borde y título.
  Widget _buildChartContainer({required String title, required Widget chart}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(126, 217, 87, 1), width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 350, height: 300, child: chart),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el gráfico de barras para mostrar los servicios más solicitados.
  Widget _buildBarChart() {
    return Chart(
      data: mapaServicios,
      variables: {
        'servicio': Variable(accessor: (Map map) => map['servicio'] as String),
        'cantidad': Variable(accessor: (Map map) => map['cantidad'] as num),
      },
      marks: [
        IntervalMark(
          label: LabelEncode(encoder: (tuple) => Label(tuple['cantidad'].toString())),
          gradient: GradientEncode(
            value: const LinearGradient(colors: [Color(0x8883bff6), Color(0x88188df0), Color(0xcc188df0)]),
          ),
        ),
      ],
      coord: RectCoord(transposed: true),
      axes: [Defaults.verticalAxis, Defaults.horizontalAxis],
    );
  }

  /// Construye el gráfico de líneas para mostrar la tendencia de citas atendidas.
  Widget _buildLineChart() {
    return Chart(
      data: timeSeriesSales,
      variables: {
        'fecha': Variable(
          accessor: (TimeSeriesSales datum) => datum.fecha,
          scale: TimeScale(formatter: (time) => _monthDayFormat.format(time)),
        ),
        'cantidad': Variable(accessor: (TimeSeriesSales datum) => datum.cantidad),
      },
      marks: [
        LineMark(
          shape: ShapeEncode(value: BasicLineShape(dash: [5, 2])),
        ),
      ],
      coord: RectCoord(color: Colors.white),
      axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
    );
  }
}
