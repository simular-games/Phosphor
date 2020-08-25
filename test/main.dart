import 'dart:io';
import 'dart:convert';
import 'package:phosphor/phosphor.dart';

void main() {
  // The settings for the client's gateway.
  var settings = GatewaySettings();
      settings.enableGatewayLogging = true;

  // Load config file and get "clientToken".
  var content = File("./test/config.json").readAsStringSync();
  var config  = json.decode(content) as Map;

  // The client we will be working with.
  Client(config["clientToken"], settings);
}
