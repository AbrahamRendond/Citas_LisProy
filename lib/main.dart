import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citas',
      home: CitasPage(),
    );
  }
}

class CitasPage extends StatefulWidget {
  @override
  _CitasPageState createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  List<Map<String, dynamic>> citas = [
    {'folio': '001', 'fechaCita': '10/10/2023', 'cliente': 'Abraham Rendon'},
    {'folio': '002', 'fechaCita': '10/11/2023', 'cliente': 'Victor Dorian'},
    {'folio': '003', 'fechaCita': '22/02/2022', 'cliente': 'Connor Kenway'},
  ];

  TextEditingController _searchController = TextEditingController();
  TextEditingController _folioController = TextEditingController();
  TextEditingController _clienteController = TextEditingController();
  DateTime? _selectedDate;
  Map<String, dynamic>? selectedCita;
  String sortCriteria = '';

  List<Map<String, dynamic>> filterCitas(String query) {
    if (query.isEmpty) {
      return citas;
    } else {
      return citas.where((cita) {
        return cita['folio'].contains(query) ||
            cita['fechaCita'].contains(query) ||
            cita['cliente'].contains(query);
      }).toList();
    }
  }

  void sortCitas(String criteria) {
    setState(() {
      if (criteria == sortCriteria) {
        citas = citas.reversed.toList();
      } else {
        citas.sort((a, b) => a[criteria].compareTo(b[criteria]));
        sortCriteria = criteria;
      }
    });
  }

  void showCitaDialog({bool isEdit = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Modificar cita' : 'Nueva cita'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _folioController,
                decoration: InputDecoration(labelText: 'Folio'),
              ),
              TextField(
                controller: _clienteController,
                decoration: InputDecoration(labelText: 'Cliente'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Mostrar selector de fecha
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  });
                },
                child: Text('Seleccionar Fecha'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (isEdit) {
                    selectedCita!['folio'] = _folioController.text;
                    selectedCita!['fechaCita'] = _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : '';
                    selectedCita!['cliente'] = _clienteController.text;
                  } else {
                    citas.add({
                      'folio': _folioController.text,
                      'fechaCita': _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : '',
                      'cliente': _clienteController.text,
                    });
                  }
                  _folioController.clear();
                  _selectedDate = null;
                  _clienteController.clear();
                });
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Guardar' : 'Crear'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar cita'),
          content: Text('¿Estás seguro de que quieres eliminar esta cita?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  citas.remove(selectedCita);
                });
                Navigator.pop(context);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Citas'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text('Folio'),
                    onSort: (columnIndex, ascending) {
                      sortCitas('folio');
                    },
                  ),
                  DataColumn(
                    label: Text('FechaCita'),
                    onSort: (columnIndex, ascending) {
                      sortCitas('fechaCita');
                    },
                  ),
                  DataColumn(
                    label: Text('Cliente'),
                    onSort: (columnIndex, ascending) {
                      sortCitas('cliente');
                    },
                  ),
                ],
                rows: filterCitas(_searchController.text)
                    .map((cita) => DataRow(
                  cells: [
                    DataCell(Text(cita['folio'])),
                    DataCell(Text(cita['fechaCita'])),
                    DataCell(Text(cita['cliente'])),
                  ],
                  selected: selectedCita == cita,
                  onSelectChanged: (value) {
                    setState(() {
                      selectedCita = cita;
                    });
                  },
                ))
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Cantidad de registros: ${filterCitas(_searchController.text).length}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Alinea los elementos al centro horizontalmente
            children: [
              ElevatedButton(
                onPressed: () {
                  showCitaDialog();
                },
                child: Text('Nuevo'),
                style: ElevatedButton.styleFrom(primary: Colors.green),
              ),
              SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: selectedCita != null
                    ? () {
                  showCitaDialog(isEdit: true);
                }
                    : null,
                child: Text('Modificar'),
                style: ElevatedButton.styleFrom(primary: Colors.orange),
              ),
              SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: selectedCita != null
                    ? () {
                  showDeleteDialog();
                }
                    : null,
                child: Text('Eliminar'),
                style: ElevatedButton.styleFrom(primary: Colors.red),
              ),
              SizedBox(width: 8.0),
            ],
          ),
        ],
      ),
    );
  }
}