import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/social_post/social_post_request.dart';
import 'package:lipa_quick/core/models/social_post/social_post_response.dart';


abstract class SocialPostEvent extends Equatable {
  const SocialPostEvent();

  @override
  List<Object> get props => [];
}

class CreatePostEvent extends SocialPostEvent {
  const CreatePostEvent({required this.content, required this.postStatus, required this.remark, required this.paymentId});
  final String content;
  final String postStatus;
  final String remark;
  final String paymentId;

  @override
  List<Object> get props => [content, postStatus, remark];
}

class GetPostEvent extends SocialPostEvent {
  String? visibilty, sortBy;

  GetPostEvent(this.visibilty, this.sortBy);
}

class GetPagedPostContent extends SocialPostEvent {
  String? visibilty, sortBy;

  GetPagedPostContent(this.visibilty, this.sortBy);
}

class SocialPostLikeEvent extends SocialPostEvent {
  const SocialPostLikeEvent({required this.socialPostCreate, required this.isLiked, required this.position});
  final PostItem socialPostCreate;
  final bool isLiked;
  final int position;

  @override
  List<Object> get props => [socialPostCreate];
}

class SocialApplaudEvent extends SocialPostEvent {
  const SocialApplaudEvent({required this.socialPostCreate, required this.isApplaud, required this.position});
  final PostItem socialPostCreate;
  final bool isApplaud;
  final int position;

  @override
  List<Object> get props => [socialPostCreate];
}

class SocialThumbsUpEvent extends SocialPostEvent {
  const SocialThumbsUpEvent({required this.socialPostCreate, required this.isThumbsUp, required this.position});
  final PostItem socialPostCreate;
  final bool isThumbsUp;
  final int position;

  @override
  List<Object> get props => [socialPostCreate];
}