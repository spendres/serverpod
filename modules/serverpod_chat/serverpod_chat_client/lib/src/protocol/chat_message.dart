/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'package:serverpod_auth_client/module.dart' as _i2;
import 'protocol.dart' as _i3;

/// A chat message.
abstract class ChatMessage extends _i1.SerializableEntity {
  ChatMessage._({
    this.id,
    required this.channel,
    required this.message,
    required this.time,
    required this.sender,
    this.senderInfo,
    required this.removed,
    this.clientMessageId,
    this.sent,
    this.attachments,
  });

  factory ChatMessage({
    int? id,
    required String channel,
    required String message,
    required DateTime time,
    required int sender,
    _i2.UserInfoPublic? senderInfo,
    required bool removed,
    int? clientMessageId,
    bool? sent,
    List<_i3.ChatMessageAttachment>? attachments,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return ChatMessage(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      channel: serializationManager
          .deserialize<String>(jsonSerialization['channel']),
      message: serializationManager
          .deserialize<String>(jsonSerialization['message']),
      time:
          serializationManager.deserialize<DateTime>(jsonSerialization['time']),
      sender:
          serializationManager.deserialize<int>(jsonSerialization['sender']),
      senderInfo: serializationManager
          .deserialize<_i2.UserInfoPublic?>(jsonSerialization['senderInfo']),
      removed:
          serializationManager.deserialize<bool>(jsonSerialization['removed']),
      clientMessageId: serializationManager
          .deserialize<int?>(jsonSerialization['clientMessageId']),
      sent: serializationManager.deserialize<bool?>(jsonSerialization['sent']),
      attachments:
          serializationManager.deserialize<List<_i3.ChatMessageAttachment>?>(
              jsonSerialization['attachments']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The channel this message was posted to.
  String channel;

  /// The body of the message.
  String message;

  /// The time when this message was posted.
  DateTime time;

  /// The user id of the sender.
  int sender;

  /// Information about the sender.
  _i2.UserInfoPublic? senderInfo;

  /// True, if this message has been removed.
  bool removed;

  /// The client message id, used to track if a message has been delivered.
  int? clientMessageId;

  /// True if the message has been sent.
  bool? sent;

  /// List of attachments associated with this message.
  List<_i3.ChatMessageAttachment>? attachments;

  ChatMessage copyWith({
    int? id,
    String? channel,
    String? message,
    DateTime? time,
    int? sender,
    _i2.UserInfoPublic? senderInfo,
    bool? removed,
    int? clientMessageId,
    bool? sent,
    List<_i3.ChatMessageAttachment>? attachments,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel': channel,
      'message': message,
      'time': time,
      'sender': sender,
      'senderInfo': senderInfo,
      'removed': removed,
      'clientMessageId': clientMessageId,
      'sent': sent,
      'attachments': attachments,
    };
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    int? id,
    required String channel,
    required String message,
    required DateTime time,
    required int sender,
    _i2.UserInfoPublic? senderInfo,
    required bool removed,
    int? clientMessageId,
    bool? sent,
    List<_i3.ChatMessageAttachment>? attachments,
  }) : super._(
          id: id,
          channel: channel,
          message: message,
          time: time,
          sender: sender,
          senderInfo: senderInfo,
          removed: removed,
          clientMessageId: clientMessageId,
          sent: sent,
          attachments: attachments,
        );

  @override
  ChatMessage copyWith({
    Object? id = _Undefined,
    String? channel,
    String? message,
    DateTime? time,
    int? sender,
    Object? senderInfo = _Undefined,
    bool? removed,
    Object? clientMessageId = _Undefined,
    Object? sent = _Undefined,
    Object? attachments = _Undefined,
  }) {
    return ChatMessage(
      id: id is int? ? id : this.id,
      channel: channel ?? this.channel,
      message: message ?? this.message,
      time: time ?? this.time,
      sender: sender ?? this.sender,
      senderInfo: senderInfo is _i2.UserInfoPublic?
          ? senderInfo
          : this.senderInfo?.copyWith(),
      removed: removed ?? this.removed,
      clientMessageId:
          clientMessageId is int? ? clientMessageId : this.clientMessageId,
      sent: sent is bool? ? sent : this.sent,
      attachments: attachments is List<_i3.ChatMessageAttachment>?
          ? attachments
          : this.attachments?.clone(),
    );
  }
}
