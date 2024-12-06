import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _ageController = TextEditingController();
  final _bmiController = TextEditingController();
  final _bpController = TextEditingController(); // Expected format: "120/80"
  final _glucoseController = TextEditingController();

  String prediction = "Prediction will appear here.";
  String percentage = "Percentage will appear here.";

  Future<void> _getPrediction() async {
    try {
      // Validate and parse BP
      List<String> bpValues = _bpController.text.split('/');
      if (bpValues.length != 2) {
        setState(() {
          prediction = "Invalid blood pressure format. Use '120/80' format.";
          percentage = "N/A";
        });
        return;
      }

      int systolic = int.parse(bpValues[0].trim());
      int diastolic = int.parse(bpValues[1].trim());

      // Send the request
      final url = Uri.parse('http://127.0.0.1:5000/predict');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "age": int.parse(_ageController.text),
          "bmi": double.parse(_bmiController.text),
          "systolic": systolic,
          "diastolic": diastolic,
          "glucose": double.parse(_glucoseController.text),
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          prediction = result['prediction'];
          percentage = "${result['probability'].toStringAsFixed(2)}%";
        });
      } else {
        setState(() {
          prediction = "Error in prediction.";
          percentage = "N/A";
        });
      }
    } catch (e) {
      setState(() {
        prediction = "Invalid input. Please check your entries.";
        percentage = "N/A";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Prediction'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter your details', style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _bmiController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'BMI',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _bpController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Blood Pressure (Systolic/Diastolic)',
                  hintText: 'e.g., 120/80',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _glucoseController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Glucose Level',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getPrediction,
                child: Text('Get Prediction'),
              ),
              SizedBox(height: 20),
              Text(
                'Prediction: $prediction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Likelihood of getting diabetes: $percentage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
