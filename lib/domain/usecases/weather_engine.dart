import '../../data/models/weather_model.dart';

class WeatherEngine {
  static const List<WeatherType> _weatherCycle = [
    WeatherType.sunny,
    WeatherType.sunny,
    WeatherType.rainy,
    WeatherType.sunny,
    WeatherType.foggy,
    WeatherType.rainy,
    WeatherType.snowy,
  ];

  /// Returns active weather condition based on in-game day (§4.6.5)
  static WeatherType getWeatherForDay(int inGameDay) {
    final index = (inGameDay - 1) % _weatherCycle.length;
    return _weatherCycle[index];
  }

  /// Calculates combined weather multiplier for a vehicle category
  static double getVehicleDemandMultiplier(WeatherType weather, String bodyType) {
    return switch (bodyType) {
      'SUV' || '4x4' => weather.suvDemandMultiplier,
      'Spor' || 'Cabrio' => weather.sportDemandMultiplier,
      _ => 1.0,
    };
  }
}
