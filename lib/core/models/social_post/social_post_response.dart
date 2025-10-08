import 'package:json_annotation/json_annotation.dart';

class SocialPostResponse {
  @JsonKey(name: 'status', defaultValue: false)
  bool? status;
  @JsonKey(name: 'message', defaultValue: '')
  String? message;
  @JsonKey(name: 'skip', defaultValue: 0)
  int? skip;
  @JsonKey(name: 'pageSize', defaultValue: 0)
  int? pageSize;
  @JsonKey(name: 'total', defaultValue: 0)
  int? totalPosts;
  @JsonKey(name: 'data')
  List<PostItem>? data;

  SocialPostResponse.name({this.status, this.message
              ,this.skip,this.pageSize, this.totalPosts, this.data});

  factory SocialPostResponse.fromJson(Map<String, dynamic> json) =>
      SocialPostResponse.name(
        status: json['status'] ?? false,
        message: json['message'] ?? '',
        skip: json['skip'] ?? 0,
        pageSize: json['pageSize'] ?? 0,
        totalPosts: json['total'] ?? 0,
        data: (json['data'] as List<dynamic>?)
            ?.map((e) => PostItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PostItem {
  final String? id, userId, userName, avatar, postContent, modifiedAt, remarks;
  int postStatus, like, thumbsUp, applaud;
  bool? isLiked, isThumbsUp, isApplauded;

  PostItem.init(
      this.id, this.userId,this.userName,this.avatar, this.postContent, this.postStatus
      , this.modifiedAt, this.like, this.thumbsUp, this.applaud
      ,{this.isLiked, this.isThumbsUp, this.isApplauded, this.remarks});

  factory PostItem.fromJson(Map<String, dynamic> json) =>
      PostItem.init(json['id'] ?? ''
        , json['userId'] ?? ''
        , json['userName'] ?? ''
        , json['avatar'] ?? ''
          , json['postContent'] ?? ''
          , json['postStatus'] ?? 0
          , json['modifiedAt'] ?? ''
          , json['like'] ?? 0
          , json['thumbsUp'] ?? 0
          , json['applaud'] ?? 0,
        isLiked: json['isLiked'] ?? false,
        isThumbsUp: json['isThumbsUp'] ?? false,
        isApplauded: json['isApplauded'] ?? false,
        remarks: json['remarks'] ?? '',
      );


  @override
  String toString() {
    return 'PostItem{id: $id, userName: $userName, like: $like, thumbsUp: $thumbsUp, applaud: $applaud,isLiked: $isLiked isThumbsUp: $isThumbsUp, isApplauded: $isApplauded}';
  }

  @override
  int get hashCode => id!.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostItem &&
          runtimeType == other.runtimeType &&
          id == other.id;
}
