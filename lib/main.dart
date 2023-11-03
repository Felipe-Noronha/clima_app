import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do Tempo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiKey = '0746e4cc79edf564a7b89c68bc5eaa25';
  Map<String, dynamic>? weatherData;
  TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _getWeatherData();
    } else {
      // Permissão não concedida, lidar com isso conforme necessário
    }
  }

  Future<void> _getWeatherData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;

      final response = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        throw Exception('Erro ao carregar dados do clima');
      }
    } catch (e) {
      print('Erro ao obter dados do clima: $e');
    }
  }

  Future<void> _getWeatherDataByCity(String cityName) async {
    // Oculta o teclado
    FocusScope.of(context).unfocus();

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        throw Exception('Erro ao carregar dados do clima');
      }
    } catch (e) {
      print('Erro ao obter dados do clima: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previsão do Tempo'),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.avif'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Digite o nome da cidade',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _getWeatherDataByCity(_cityController.text);
                },
                child: Text('Pesquisar'),
              ),
              weatherData == null
                  ? CircularProgressIndicator()
                  : Column(
                      children: <Widget>[
                        Text(
                          'Cidade: ${weatherData!['name']}',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Condição: ${weatherData!['weather']?[0]['description'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Temperatura: ${(weatherData!['main']?['temp'] - 273.15)?.toStringAsFixed(2) ?? 'N/A'} °C',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
