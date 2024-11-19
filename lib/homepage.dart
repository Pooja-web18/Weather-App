import 'package:flutter/material.dart';
import 'package:new_weather/api.dart';
import 'package:new_weather/weathermodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiResponse? response;
  bool inProgress = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchWidget(),
              const SizedBox(height: 20),
              if (inProgress) CircularProgressIndicator()
              else
                Expanded(
                  child: SingleChildScrollView(child: _buildWeatherWidget()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchWidget() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search any Location",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search),
      ),
      onSubmitted: (value) {
        _getWeatherData(value);
      },
    );
  }

  Widget _buildWeatherWidget() {
    if (response == null) {
      return Text("Search for the location to get weather");
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.location_on,
                size: 50,
              ),
              Text(
                response?.location?.name ?? "Unknown",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                response?.location?.country ?? "Unknown",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  (response?.current?.tempC.toString() ?? "") + "°c",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                response?.current?.condition?.text ?? "Unknown",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Center(
            child: SizedBox(
              height: 200,
              child: Image.network(
                "https:${response?.current?.condition?.icon}".replaceAll("64*64", "128*128"),
                scale: 0.7,
              ),
            ),
          ),
          Card(
            elevation: 4,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dataAndTitleWidget("Humidity", response?.current?.humidity?.toString() ?? ""),
                    _dataAndTitleWidget("Wind Speed", "${response?.current?.windKph?.toString() ?? ""} km/h")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dataAndTitleWidget("UV", response?.current?.uv?.toString() ?? ""),
                    _dataAndTitleWidget("Precipitation", "${response?.current?.precipMm?.toString() ?? ""} mm")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dataAndTitleWidget("Local Time", response?.location?.localtime?.split(" ").last ?? ""),
                    _dataAndTitleWidget("Local Date", response?.location?.localtime?.split(" ").first ?? ""),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _dataAndTitleWidget(String title, String data) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Text(
            data,
            style: const TextStyle(
              fontSize: 27,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _getWeatherData(String location) async {
    setState(() {
      inProgress = true;
    });
    try {
      ApiResponse newResponse = await WeatherAPi().getCurrentWeather(location);
      setState(() {
        response = newResponse;
      });
    } catch (e) {
      // Handle error if needed
      setState(() {
        response = null;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to load weather data. Please try again."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
