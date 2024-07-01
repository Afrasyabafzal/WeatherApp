import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temperature = 0;
  @override
  void initState() {
    super.initState();
    // getWeather().then((value) {
    //   print("Weather Data");
    //   print(value);
    //   temperature = value["list"][0]["main"]["temp"];
    // });
  }

  Future<Map<String, dynamic>> getWeather() async {
    try {
      String city = "London";
      String country = "uk";
      String apiKey = "6728f716c183566f4d7e863c74dc016f";
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city,$country&APPID=$apiKey'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw "Failed to load weather data";
      }
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getWeather(),
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          final data = snapshot.data;
          final currentdata = data?["list"][0];
          temperature = currentdata["main"]["temp"];
          final currentSky = currentdata["weather"][0]["main"];
          final currentPressure = currentdata["main"]["pressure"];
          final currentHumidity = currentdata["main"]["humidity"];
          final currentWindSpeed = currentdata["wind"]["speed"];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$temperature K',
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Icon(
                                currentSky == "Clouds" || currentSky == "Rain"
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              Text(
                                currentSky,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Weather Forecast",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data?["list"][index + 1];
                      return HourlyForecase(
                        time: hourlyForecast["dt_txt"]
                            .toString()
                            .split(" ")[1]
                            .split(":")
                            .sublist(0, 2)
                            .join(":"),
                        icon: hourlyForecast["weather"][0]["main"] ==
                                    "Clouds" ||
                                hourlyForecast["weather"][0]["main"] == "Rain"
                            ? Icons.cloud
                            : Icons.sunny,
                        temperature: hourlyForecast["main"]["temp"].toString(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Additional Details",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      title: "Humidity",
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      title: "Wind Speed",
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.beach_access,
                      title: "Pressure",
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
