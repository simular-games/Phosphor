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

/// The max size of a short, we use this during the opcode detection to signal an error.
const USHORT_MAX = 65536;

/// The settings for the gateway.
class GatewaySettings {
  /// Whether or not to enable gateway logging.
  /// When gateway logging is enabbled, the gateway will print to the console each step it's taking
  /// and any data it sends and receives.
  bool enableGatewayLogging = false;
}

/// A typedef for a function type that is called when the [_Gateway] receives a Hello message from
/// Discord. This callback will receive the sequence number and the heartbeat interval sent by
/// Discord, to cache and use later.
typedef _DiscordHelloCallback = void Function(int sequence, int heartbeat_interval);

/// The gateway is a wrapper around the Discord gateway and is used by a client to send and receive
/// data from Discord.
class _Gateway {
  /// The Discord gateway URL.
  static const GATEWAY_URL = "wss://gateway.discord.gg:443/?v=6&encoding=json";

  /// Constructs a gateway from a client token.
  /// This sets the gateway to perform an introduction to Discord for a client.
  _Gateway(this._settings) {
    _initialize();
  }

  /// Queues some data to be sent over the wire to Discord.
  /// The [data] should be a JSON formatted string containing whatever Discord expects to receive.
  void queueData(String data) {
    // Make sure we aren't getting null data.
    assert(data != null);

    // Say where we are.
    if (_settings.enableGatewayLogging) {
      print("[WebSocket] -- Sending payload:");
      print("[WebSocket] -- $data");
    }

    // Add data to send.
    _socket?.add(data);
  }

  /// Sets the Hello callback for the gateway.
  /// The provided callback will be called when the gateway receives a Hello from Discord.
  void onDiscordHello(_DiscordHelloCallback callback) {
    _helloCallback = callback;
  }

  /// Performs the initialization of the websocket and gets the information needed from Discord.
  void _initialize() {
    // Create a websocket and attempt to connect.
    WebSocket.connect(GATEWAY_URL).then(_handleConnection, onError: _handleGatewayError);
  }

  /// Handles the connection of the socket with Discord.
  void _handleConnection(WebSocket socket) {
    // Say where we are.
    if (_settings.enableGatewayLogging)
      print("[WebSocket] -- Connection began.");

    // Assign the socket and make sure the socket isn't null.
    _socket = socket;
    if (_socket?.readyState == WebSocket.open) {
      // Say what we're doing.
      if (_settings.enableGatewayLogging) {
        print("[WebSocket] -- Connected, Gateway opened.");
        print("[WebSocket] -- Listening to: $GATEWAY_URL");
      }

      // Set socket to listen.
      _socket.listen(_listenToConnection);
      return;
    }

    // Throw null socket.
    throw GatewayConnectionError();
  }

  /// Handles a gateway error when one is thrown.
  /// If a gateway error is thrown, the gateway is likely to close. The [error] contains the error
  /// that was thrown, and the [trace] has the stack trace that lead up to it. This will print out
  /// the error and the trace together. In some cases, the gateway may be re-established because the
  /// error is handlable. If it is not, the client will terminate.
  void _handleGatewayError(dynamic error, StackTrace trace) {

  }

  /// Listens for data on the connection with Discord.
  void _listenToConnection(dynamic data) {
    // Say where we are.
    if (_settings.enableGatewayLogging) {
      print("[WebSocket] -- Received payload:");
      print("[WebSocket] -- $data");
    }

    // Decode data.
    var payload = json.decode(data) as Map;
    assert(payload != null);

    // Get opcode, default to USHORT_MAX if opcode isn't present, this is an error on the server
    // size, though it should never happen.
    switch (payload["op"] as int ?? USHORT_MAX) {
    case _GatewayOpcode.HELLO:
      _handleHelloMessage(payload);
      break;
    case _GatewayOpcode.HEARTBEAT_ACK:
      _handleHeartbeatAck(payload);
      break;
    case USHORT_MAX:
      print("Non-opcode payload received.");
      break;
    }
  }

  /// Handles the heartbeat message from Discord.
  /// The [payload] is a JSON object that we received from Discord. This object was picked out
  /// because it had the "op" value of [_GatewayOpcode.HEARTBEAT] which is 10. This function is
  /// responsible for retrieving the `heartbeat_interval` from the payload. It also gets the
  /// sequence number to keep track of.
  void _handleHelloMessage(Map<dynamic, dynamic> payload) {
    // Say where we are.
    if (_settings.enableGatewayLogging)
      print("[Gateway] -- Received Discord Hello.");

    // Cache sequence.
    var sequence = payload["s"];
    if (_settings.enableGatewayLogging)
      print("[Gateway] -- sequence number #$sequence");

    // Get data section.
    var payloadDataSection = payload["d"] as Map;
    assert(payloadDataSection != null);

    // Get heartbeat_interval.
    var heartbeat_interval = payloadDataSection["heartbeat_interval"];
    if (_settings.enableGatewayLogging)
      print("[Gateway] -- heartbeat_interval is $heartbeat_interval");

    // Call the callback.
    assert(_helloCallback != null);
    _helloCallback(sequence, heartbeat_interval);
  }

  /// Handles receiving a heartbeat acknowledgement from Discord.
  /// The payload contains the data from the acknowledgement.
  void _handleHeartbeatAck(Map<dynamic, dynamic> payload) {

  }

  /// The settings for this gateway object.
  GatewaySettings _settings;

  /// The websocket connection to Discord.
  WebSocket _socket;

  /// The callback for when the gateway receives a Hello from Discord.
  _DiscordHelloCallback _helloCallback;
}
