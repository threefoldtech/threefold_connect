import 'package:threebotlogin/core/config/enums/config.enums.dart';

abstract class EnvConfig {
  Environment environment = Environment.Staging;

  String gitHash = "69d25f6";
  String time = "10:22:11 24.11.2022";
}