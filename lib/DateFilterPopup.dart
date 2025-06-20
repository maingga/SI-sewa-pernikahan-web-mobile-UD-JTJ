import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilterPopup extends StatefulWidget {
  final Function(DateTime startDate, DateTime endDate) onApply;
  final DateTime? startDate;
  final DateTime? endDate;

  DateFilterPopup({required this.onApply, this.startDate, this.endDate});

  @override
  _DateFilterPopupState createState() => _DateFilterPopupState();
}

class _DateFilterPopupState extends State<DateFilterPopup> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate ?? DateTime.now();
    _endDate = widget.endDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter berdasarkan Tanggal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text("Tanggal Mulai"),
            trailing: Text(DateFormat('dd-MM-yyyy').format(_startDate)),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked;
                });
              }
            },
          ),
          ListTile(
            title: Text("Tanggal Akhir"),
            trailing: Text(DateFormat('dd-MM-yyyy').format(_endDate)),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _endDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                setState(() {
                  _endDate = picked;
                });
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_startDate, _endDate);
            Navigator.of(context).pop();
          },
          child: Text('Terapkan'),
        ),
      ],
    );
  }
}
