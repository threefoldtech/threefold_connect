import 'package:threebotlogin/core/config/enums/config.enums.dart';

abstract class EnvConfig {
  Environment environment = Environment.Staging;

  String gitHash = "577bf43";
  String time = "17:04:06 24.11.2022";
}