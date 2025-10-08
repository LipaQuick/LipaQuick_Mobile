
import 'package:equatable/equatable.dart';
import 'package:lipa_quick/core/models/banks/bank_details.dart';
import 'package:lipa_quick/core/models/social_post/social_post_response.dart';

enum PostApiStatus { initial,loading, success, failure, authFailed, empty,  interactionFailed}

class PostState extends Equatable {
  const PostState({
    this.status = PostApiStatus.initial,
    this.socialPosts = const <PostItem>[],
    this.hasReachedMax = false,
    this.messages = '',
  });

  final PostApiStatus status;
  final List<PostItem> socialPosts;
  final bool hasReachedMax;
  final String messages;

  PostState copyWith({
    PostApiStatus? status,
    List<PostItem>? posts,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return PostState(
      status: status ?? this.status,
      socialPosts: posts ?? socialPosts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      messages: errorMessage ?? messages,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: ${socialPosts.length} }''';
  }

  @override
  List<Object> get props => [status, socialPosts, hasReachedMax, messages];
}