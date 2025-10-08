import 'package:lipa_quick/core/models/social_post/social_post_response.dart';

class SocialPostCreate{
  final String? postContent, remark, paymentId;
  final int? postStatus;

  SocialPostCreate(this.postContent, this.postStatus, this.remark, this.paymentId);

  Map<String, dynamic> toJSON() =>
      <String, dynamic>{
        'postContent': postContent,
        'postStatus': postStatus,
        'remarks': remark,
        'paymentId': paymentId
      };
  PostItem toPostItem() =>
      PostItem.init('','',remark,'', postContent, postStatus!, '', 0,0,0);
}