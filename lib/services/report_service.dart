import 'package:barberapp/views/screens/report_screen.dart';
import 'package:barberapp/models/cita_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para gestionar las citas en Firestore
class report_service {
  // Referencia a la colección 'citas' en Firestore
  final CollectionReference _citaCollection = FirebaseFirestore.instance.collection('citas');

  /// Obtiene la lista de clientes de la colección 'citas'
  Future<List> getClientList() async {
    QuerySnapshot querySnapshot = await _citaCollection.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Obtiene la lista de citas filtradas por cliente
  Future<List<Cita>> getCitasbyCliente(String cliente) async {
    QuerySnapshot querySnapshot = await _citaCollection.where("cliente", isEqualTo: cliente).get();
    return querySnapshot.docs.map((doc) => Cita.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  /// Agrega una nueva cita a Firestore utilizando el código como identificador
  Future<void> addCita(Cita cita) async {
    await _citaCollection.doc(cita.codigo).set(cita.toMap());
  }

  /// Obtiene los servicios más solicitados en el último mes
  Future<List<Map<String, dynamic>>> getServiciosSolicitadosMensuales() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month - 1, now.day);

    Timestamp startTimestamp = Timestamp.fromDate(DateTime(now.year, 1, 1));
    Timestamp endTimestamp = Timestamp.fromDate(DateTime(now.year, 12, 1));

    QuerySnapshot querySnapshot = await _citaCollection.get();

    Map<String, dynamic> serviciosMensuales = {};
    List<Map<String, dynamic>> listaServiciosMensuales = [];

    List<Cita> citas = querySnapshot.docs.map((doc) => Cita.fromMap(doc.data() as Map<String, dynamic>)).toList();

    // Recorre todas las citas para contar los servicios más solicitados
    for (var cita in citas) {
      for (var s in cita.servicios) {
        if (serviciosMensuales.containsKey(s)) {
          serviciosMensuales[s]++;
        } else {
          serviciosMensuales[s.trim()] = 1;
        }
      }
    }

    // Convierte los datos a una lista de mapas
    serviciosMensuales.forEach((servicio, cantidad) =>
        listaServiciosMensuales.add({'servicio': servicio, 'cantidad': cantidad}));

    return listaServiciosMensuales;
  }

  /// Obtiene el número de citas atendidas por fecha y las convierte en datos de serie temporal
  Future<List<TimeSeriesSales>> getCitasAtendidas() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month - 1, now.day);

    Timestamp startTimestamp = Timestamp.fromDate(DateTime(now.year, 1, 1));
    Timestamp endTimestamp = Timestamp.fromDate(DateTime(now.year, 12, 1));

    QuerySnapshot querySnapshot = await _citaCollection.get();

    Map<DateTime, dynamic> citasAtendidas = {};
    List<TimeSeriesSales> timeSeriesSales = [];

    List<Cita> citas = querySnapshot.docs.map((doc) => Cita.fromMap(doc.data() as Map<String, dynamic>)).toList();

    // Recorre todas las citas y cuenta la cantidad atendida por fecha
    for (var cita in citas) {
      if (citasAtendidas.containsKey(cita.fecha)) {
        citasAtendidas[cita.fecha]++;
      } else {
        citasAtendidas[cita.fecha] = 1;
      }
    }

    // Convierte los datos en una lista de objetos TimeSeriesSales
    citasAtendidas.forEach((fecha, cantidad) {
      timeSeriesSales.add(TimeSeriesSales(
          DateTime(fecha.year, fecha.month, fecha.day), cantidad + 10));
      timeSeriesSales.add(TimeSeriesSales(
          DateTime(fecha.year, fecha.month, fecha.day + 1), cantidad + 23));
    });

    return timeSeriesSales;
  }
}