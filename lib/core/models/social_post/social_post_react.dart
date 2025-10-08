class SocialPostReactionRequest{
  String? postId, friendId;
  bool? like, thumbsUp, applaud;

  SocialPostReactionRequest(
      this.postId, this.friendId, this.like, this.thumbsUp, this.applaud);

  Map<String, dynamic> toJSON() =>
      <String, dynamic>{
        'postId': postId,
        'friendId': friendId,
        'like': like,
        'thumbsUp': thumbsUp,
        'applaud': applaud,
      };
}