
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'monday_service.dart';

class MondayDemoPage extends StatefulWidget {
  @override
  _MondayDemoPageState createState() => _MondayDemoPageState();
}

class _MondayDemoPageState extends State<MondayDemoPage> {
  final _svc = MondayService();
  String _status = 'Idle';

  Future<void> _sendTest() async {
    setState(() => _status = 'Sending...');
    try {
      await dotenv.load(fileName: ".env");
      final id = await _svc.createAppointment(
        clientName: "John Doe",
        type: "Client Appointment",
        dateTime: DateTime.now().add(Duration(days: 1)),
        notes: "Test appointment from Flutter app",
      );
      setState(() => _status = 'Success! Item ID $id');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Monday.com Demo')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_status),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendTest,
                child: Text('Send Test Appointment'),
              )
            ],
          ),
        ),
      );
}
