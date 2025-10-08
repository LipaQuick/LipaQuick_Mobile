class ChatResponse {

  bool? _status;
  int? _skip;
  int? _pageSize;
  int? _total;
  String? message;
  List<ChatMessage>? _data;

  ChatResponse({bool? status, int? skip, int? pageSize, int? total, String? message, List<ChatMessage>? data}) {
    _status = status;
    _skip = skip;
    _pageSize = pageSize;
    _total = total;
    _data = data;
    this.message = message;
  }

  bool get status => _status!;
  set status(bool status) => _status = status!;
  int get skip => _skip!;
  set skip(int skip) => _skip = skip;
  int get pageSize => _pageSize!;
  set pageSize(int pageSize) => _pageSize = pageSize;
  int get total => _total!;
  set total(int total) => _total = total;
  List<ChatMessage> get data => _data!;
  set data(List<ChatMessage> data) => _data = data;

  ChatResponse.fromJson(Map<String, dynamic> json) {
    _status = json['status'];
    _skip = json['skip'];
    _pageSize = json['pageSize'];
    _total = json['total'];
    if (json['data'] != null) {
      _data = <ChatMessage>[];
      json['data'].forEach((v) {
        _data?.add(ChatMessage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = _status;
    data['skip'] = _skip;
    data['pageSize'] = _pageSize;
    data['total'] = _total;
    if (_data != null) {
      data['data'] = _data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChatMessage {
  String? _id;
  String? _sender;
  String? _receiver;
  String? _message;
  String? _chatDoc;
  bool? _self;
  String? _modifiedAt;


  ChatMessage(this._id, this._sender, this._receiver, this._message, this._chatDoc,
      this._self, this._modifiedAt);

  String get id => _id!;
  set id(String id) => _id = id;
  String get sender => _sender!;
  set sender(String sender) => _sender = sender;
  String get receiver => _receiver!;
  set receiver(String receiver) => _receiver = receiver;
  String get message => _message!;
  set message(String message) => _message = message;
  String get chatDoc => _chatDoc!;
  set chatDoc(String chatDoc) => _chatDoc = chatDoc;
  bool get self => _self!;
  set self(bool self) => _self = self;
  String get modifiedAt => _modifiedAt!;
  set modifiedAt(String modifiedAt) => _modifiedAt = modifiedAt;

  ChatMessage.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _sender = json['sender'];
    _receiver = json['receiver'];
    _message = json['message'];
    _chatDoc = json['chatDoc'];
    _self = json['self'];
    _modifiedAt = json['modifiedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['sender'] = _sender;
    data['receiver'] = _receiver;
    data['message'] = _message;
    data['chatDoc'] = _chatDoc;
    data['self'] = _self;
    data['modifiedAt'] = _modifiedAt;
    return data;
  }
}