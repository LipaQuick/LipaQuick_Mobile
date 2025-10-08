
// Events
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';

abstract class SignalREvent extends Equatable {
  const SignalREvent();
  @override
  List<Object?> get props => [];
}

class ConnectEvent extends SignalREvent {
  const ConnectEvent();
}
class DisposeEvent extends SignalREvent {
  const DisposeEvent();
}

class DisconnectEvent extends SignalREvent {
  const DisconnectEvent();
}

class IncomingMessageEvent extends SignalREvent {
  final List<Object?>? args;

  IncomingMessageEvent(this.args);

  @override
  List<Object?> get props => [args];
}

class LoadMoreEvent extends SignalREvent {
  const LoadMoreEvent();
}

class LoadInitialMessagesEvent extends SignalREvent {
  const LoadInitialMessagesEvent();
}

class FileDownloadEvent extends SignalREvent {
  final FileMessage? message;
  const FileDownloadEvent(this.message);
}
class SignalRFindUserDetailsEvent extends SignalREvent {
  final String? receiversId;
  SignalRFindUserDetailsEvent(this.receiversId);
}

class SendMessagesEvent extends SignalREvent {
  final RecentChats chats;
  final String message;

  SendMessagesEvent(this.chats, this.message);

  @override
  List<Object?> get props => [chats, message];
}

class SignalRUploadEvent extends SignalREvent{
  final File? file;
  SignalRUploadEvent(this.file);
}

class SignalRMessageDelete extends SignalREvent{
  final String? messageId;
  final int? position;
  const SignalRMessageDelete(this.messageId, this.position);
}

