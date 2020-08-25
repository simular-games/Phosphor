/* Copyright (c) 2020 Simular Games, LLC.
 * -------------------------------------------------------------------------------------------------
 *
 * MIT License
 * -------------------------------------------------------------------------------------------------
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 * -------------------------------------------------------------------------------------------------
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
part of phosphor;

/// A client in phosphor is responsible for handling the connection and events of the connection
/// with the discord gateway.
class Client {
  /// The name of the library.
  static const LIBRARY_NAME = "Phosphor (p15)";

  /// Creates a new client with the given token and gateway settings.
  Client(this._token, GatewaySettings gatewaySettings)
    : _gateway = _Gateway(gatewaySettings)
  {
    _gateway.onDiscordHello(_loginWithToken);
  }

  /// Login to Discord with the token that this class was created with
  void _loginWithToken(int sequence, int heartbeat_interval) {
    // Assign our properties.
    _sequence           = sequence;
    _heartbeat_interval = heartbeat_interval;

    // Create heartbeater.
    _heartbeater = Timer.periodic(Duration(milliseconds: _heartbeat_interval), _sendHeartbeat);

    // Immediately send our identification payload.
    var obj = {
      "op": _GatewayOpcode.IDENTIFY,
      "d": {
        "token": _token,
        "properties": {
          "\$os": Platform.operatingSystem,
          "\$browser": LIBRARY_NAME,
          "\$device": LIBRARY_NAME
        }
      }
    };

    // Send data to Discord.
    _gateway.queueData(json.encode(obj));
  }


  void _sendHeartbeat(Timer timer) {
    // Create heartbeat object.
    var obj = {
      "op": _GatewayOpcode.HEARTBEAT,
      "d": _sequence
    };

    // Send data to Discord.
    _gateway.queueData(json.encode(obj));
  }

  /// The gateway to using Discord's API with this client.
  final _Gateway _gateway;

  /// The token to login with this client.
  final String _token;

  /// The timer we will use to run our heartbeat.
  Timer _heartbeater;

  /// The current sequence we are on with Discord.
  int _sequence = 0;

  /// The heartbeat interval Discord wants us to respond with.
  int _heartbeat_interval = 0;
}
