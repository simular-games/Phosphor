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

/// Defines the opcodes that the [Gateway] will experience on a regular.
/// Instead of using an enum we decide to use this because the close events and other opcodes will
/// end up having to go into a class just like this.
class _GatewayOpcode {
  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// the client will receive this opcode, and it's the server telling us that an event was
  /// dispatched to us.
  static const DISPATCH = 0;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// We may occasionally receive this, but mostly we'll be sending it to the server to keep the
  /// connection alive.
  static const HEARTBEAT = 1;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// the client will send this during the handshake to identify ourselves with Discord.
  static const IDENTIFY = 2;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// the client will send this when it wants to update it's presence.
  static const PRESENCE_UPDATE = 3;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// the client will send this when joining/leaving or moving between voice channels.
  static const VOICE_STATE_UPDATE = 4;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// the client will send this to attempt to resume a previously zombied or cut connection.
  static const RESUME = 6;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// the client will receive this opcode. It should attempt to reconnect or resume immediately.
  static const RECONNECT = 7;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// the client will send this opcode when it wants to get information about offline guild members.
  static const REQUEST_GUILD_MEMBERS = 8;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// the client will receive this opcode when the session has been invalidated. The client should
  /// reconnect and identify/resume accordingly.
  static const INVALID_SESSION = 9;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// the client will receive this opcode when connecting. It contains the heartbeat_interval to use.
  static const HELLO = 10;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes):
  /// the client will receive this opcode, usually, after sending a heartbeat. It acknowledges the
  /// heartbeat. If the heartbeat wasn't acknowledged, then the client should consider itself
  /// zombified and attempt reconnection.
  static const HEARTBEAT_ACK = 11;
}

/// Defines the close event codes that the [Gateway] will experience.
/// Instead of using an enum we decide to use this because they need default values which
/// enumerations don't allow.
class _GatewayCloseCodes {
  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event code is sent when an unknown error occurred.
  static const UNKNOWN_ERROR = 4000;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event code is sent when the client sends an invalid opcode.
  static const UNKNOWN_OPCODE = 4001;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event code is sent when the client sends an invalid payload to Discord's API.
  static const DECODE_ERROR = 4002;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event code is sent when the client tried to send a payload prior to identifying.
  static const NOT_AUTHENTICATED = 4003;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event is sent when the account token, sent with the client identification payload,
  /// is incorrect.
  static const AUTHENTICATION_FAILED = 4004;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event is sent when the client has already identified and attempts to send another
  /// identification payload.
  static const ALREADY_AUTHENTICATED = 4005;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event is sent when the client attempts to resume and the sequence for the session
  /// was invalid. The client should reconnect and start a new session.
  static const INVALID_SEQUENCE = 4007;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event is sent when the client sends too many payloads too quickly. It will
  /// immediately disconnect the client.
  static const RATE_LIMITED = 4008;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event is sent to the client when the client session times out. The client should
  /// initiate a new session afterwards.
  static const SESSION_TIMED_OUT = 4009;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event is sent to the client when the client sends an invalid shard to Discord.
  static const INVALID_SHARD = 4010;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event is sent when the client session would have handled too many guilds. The
  /// client is required to shard their connection in order to connect when this happens.
  static const SHARDING_REQUIRED = 4011;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event is sent to the client when they make a connection with an invalid version for
  /// the Discord gateway.
  static const INVALID_API_VERSION = 4012;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event is sent to the client when they send an invalid gateway intent, this could be
  /// because the bitwise value was incorrectly calculated.
  static const INVALID_INTENTS = 4013;

  /// As stated [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes):
  /// this close event is sent to the client when they send a disallowed gateway intent. This may be
  /// because the client is not whitelisted.
  static const DISALLOWED_INTENTS = 4014;
}
