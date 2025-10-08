import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:lipa_quick/core/managers/social_post/social_event.dart';
import 'package:lipa_quick/core/managers/social_post/social_state.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/models/social_post/social_post_react.dart';
import 'package:lipa_quick/core/models/social_post/social_post_request.dart';
import 'package:lipa_quick/core/models/social_post/social_post_response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/utils/jwt_utils.dart';

class SocialPostBloc extends Bloc<SocialPostEvent, PostState> {
  Api api;
  late String? visibilty, sortby;
  int _currentPage = 0;
  int totalPageSize  = 0;
  final int PAGE_SIZE = 30;
  final String IDENTIFIER = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';

  SocialPostBloc(this.api) : super(PostState()) {
    on<GetPostEvent>(_getSocialPost);
    on<GetPagedPostContent>(_getPageSocialPost);
    on<CreatePostEvent>(_createPostEvent);
    on<SocialPostLikeEvent>(_reactSocialPostEvent);
    on<SocialApplaudEvent>(_reactApplaudEvent);
    on<SocialThumbsUpEvent>(_reactThumbsEvent);
  }

  FutureOr<void> _getSocialPost(
      GetPostEvent event, Emitter<PostState> emit) async {
    //print('Current State ${state.status.name}');
    visibilty = event.visibilty;
    sortby = event.sortBy;
    totalPageSize = 0;
    _currentPage = 0;

    emit(state.copyWith(status: PostApiStatus.loading));

    var apiresponse =
        await api.getAllSocialPost(_currentPage, PAGE_SIZE, event.visibilty, event.sortBy);
    if (apiresponse is APIException) {
      if(apiresponse.statusCode == 404){
       return emit(state.copyWith(
          status: PostApiStatus.empty,
        ));
      }

      if (apiresponse.message != null &&
          apiresponse.message!.contains("Unauthorized access")) {
        return emit(state.copyWith(
          status: PostApiStatus.authFailed,
        ));
      }

      emit(state.copyWith(
        status: PostApiStatus.failure,
      ));
    } else {
      var result = apiresponse as SocialPostResponse;
      totalPageSize = result.totalPosts!;
      if (kDebugMode) {
        print("${result == null}");
      }


      if (result.data!.isEmpty) {
        return emit(state.copyWith(
          status: PostApiStatus.empty,
        ));
      } else {
        return emit(
            state.copyWith(status: PostApiStatus.success, posts: result.data));
      }
    }
  }

  String getErrorMessage(List<String> errors) {
    var buffer = StringBuffer();
    for (var i = 0; i < errors.length; i++) {
      buffer.write('${(i + 1)}. ${errors[i]}\n');
    }
    return buffer.toString();
  }

  FutureOr<void> _getPageSocialPost(GetPagedPostContent event, Emitter<PostState> emit) async {
    visibilty = event.visibilty;
    sortby = event.sortBy;

    emit(state.copyWith(status: PostApiStatus.loading));

    if(state.socialPosts.isNotEmpty && state.socialPosts.length-1
          == totalPageSize){
        _currentPage++;
      }

    var apiresponse =
        await api.getAllSocialPost(0, 30, event.visibilty, event.sortBy);
    if (apiresponse is APIException) {
      if(apiresponse.statusCode == 404){
        return emit(state.copyWith(
          status: PostApiStatus.empty,
        ));
      }
      emit(state.copyWith(
        status: PostApiStatus.failure,
        errorMessage: apiresponse.errors != null && apiresponse.errors!.isNotEmpty
          ? getErrorMessage(apiresponse.errors!): apiresponse.message!
          //done
      ));
    }
    else {
      var result = apiresponse as SocialPostResponse;
      //totalPageSize = result.totalPosts!;
      if (kDebugMode) {
        print("${result == null}");
      }
      if (apiresponse.message != null &&
          apiresponse.message!.contains("Unauthorized access")) {
        emit(state.copyWith(
          status: PostApiStatus.authFailed,
        ));
      }

      if (result.data!.isEmpty) {
        return emit(state.copyWith(
          status: PostApiStatus.success,
          posts: state.socialPosts
        ));
      } else {
        var posts = state.socialPosts;
        posts.addAll(result.data!);
        return emit(
            state.copyWith(status: PostApiStatus.success, posts: posts));
      }
    }
  }

  FutureOr<void> _createPostEvent(
      CreatePostEvent event, Emitter<PostState> emit) async {
    emit(state.copyWith(
      status: PostApiStatus.loading,
    ));
    SocialPostCreate postCreate =
        SocialPostCreate(event.content, int.tryParse(event.postStatus), event.remark, event.paymentId);
    var apiresponse = await api.createSocialPost(postCreate);
    if (apiresponse is APIException) {
      emit(state.copyWith(
        status: PostApiStatus.failure,
        errorMessage: apiresponse.errors != null
          && apiresponse.errors!.isNotEmpty?getErrorMessage(apiresponse.errors!)
            :apiresponse.message!
      ));
    } else {
      var result = apiresponse as ApiResponse;
      if (kDebugMode) {
        print("${result == null}");
      }
      if (apiresponse.message != null &&
          apiresponse.message!.contains("Unauthorized access")) {
        emit(state.copyWith(
          status: PostApiStatus.authFailed,
        ));
      }

      var data = <PostItem>[];
      // if (state.socialPosts.isNotEmpty) {
      //   data = state.socialPosts;
      // }
      // data.add(postCreate.toPostItem());
      return emit(state.copyWith(status: PostApiStatus.success, posts: data));
    }
  }

  FutureOr<void> _reactSocialPostEvent(
      SocialPostLikeEvent event, Emitter<PostState> emit) async {
    emit(state.copyWith(status: PostApiStatus.loading));

    var postItem = event.socialPostCreate;
    var oldItem = event.socialPostCreate;
    int indexOfCurrentItem = state.socialPosts.indexOf(postItem);

    debugPrint('Current Index: ${indexOfCurrentItem}');

    debugPrint('Old Item: ${postItem.toString()}');

    postItem = itemLiked(postItem, event);

    debugPrint('Updated Item: ${postItem.toString()}');


    List<PostItem> socialPosts = state.socialPosts;

    socialPosts[indexOfCurrentItem] = postItem;

    emit(PostState(status: PostApiStatus.success,
        socialPosts: socialPosts, hasReachedMax: false));

    String token = "";
    await LocalSharedPref().getToken().then((value) {
      token = value;
    });
    Map<String, dynamic> tokenDecoded = JWTHelper().decodeJwt(token);
    String userID = tokenDecoded[
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];

    SocialPostReactionRequest request = SocialPostReactionRequest(
        event.socialPostCreate.id, userID, event.isLiked, false, false);
    var apiresponse = await api.socialPostReact(request);
    if (apiresponse is APIException) {

      List<PostItem> socialPosts = state.socialPosts;

      socialPosts[indexOfCurrentItem] = oldItem;

      emit(state.copyWith(
        errorMessage: apiresponse.message,
        status: PostApiStatus.interactionFailed,
      ));

      emit(state.copyWith(
          status: PostApiStatus.success,
          posts: socialPosts
      ));

    } else {
      var result = apiresponse as ApiResponse;
      if (kDebugMode) {
        print("${result == null}");
      }
      if (apiresponse.message != null &&
          apiresponse.message!.contains("Unauthorized access")) {
        state.socialPosts[indexOfCurrentItem] = oldItem;

        emit(state.copyWith(
            status: PostApiStatus.success,
            posts: state.socialPosts
        ));

        emit(state.copyWith(
          status: PostApiStatus.authFailed,
        ));
      }
    }
  }

  FutureOr<void> _reactApplaudEvent(
      SocialApplaudEvent event, Emitter<PostState> emit) async {
    emit(state.copyWith(status: PostApiStatus.loading));

    var postItem = event.socialPostCreate;
    var oldItem = event.socialPostCreate;
    int indexOfCurrentItem = state.socialPosts.indexOf(postItem);

    postItem = itemAppluaded(postItem, event);

    List<PostItem> socialPosts = state.socialPosts;

    socialPosts[indexOfCurrentItem] = postItem;

    emit(PostState(status: PostApiStatus.success,
        socialPosts: socialPosts, hasReachedMax: false));

    String token = "";
    await LocalSharedPref().getToken().then((value) {
      token = value;
    });
    Map<String, dynamic> tokenDecoded = JWTHelper().decodeJwt(token);
    String userID = tokenDecoded[
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];

    SocialPostReactionRequest request = SocialPostReactionRequest(
        event.socialPostCreate.id, userID, false, false, event.isApplaud);
    var apiresponse = await api.socialPostReact(request);

    if (apiresponse is APIException) {

      state.socialPosts[indexOfCurrentItem] = oldItem;

      emit(state.copyWith(
        errorMessage: apiresponse.message,
        status: PostApiStatus.interactionFailed,
      ));

      emit(state.copyWith(
          status: PostApiStatus.success,
          posts: state.socialPosts
      ));

    } else {
      var result = apiresponse as ApiResponse;
      if (kDebugMode) {
        print("${result == null}");
      }
      if (apiresponse.message != null &&
          apiresponse.message!.contains("Unauthorized access")) {
        state.socialPosts[indexOfCurrentItem] = oldItem;

        emit(state.copyWith(
            status: PostApiStatus.success,
            posts: state.socialPosts
        ));

        emit(state.copyWith(
          status: PostApiStatus.authFailed,
        ));
      }
    }
  }

  FutureOr<void> _reactThumbsEvent(
      SocialThumbsUpEvent event, Emitter<PostState> emit) async {
     emit(state.copyWith(status: PostApiStatus.loading));

    var postItem = event.socialPostCreate;
    int indexOfCurrentItem = state.socialPosts.indexOf(postItem);
    debugPrint('ThumbsUp Post Item: ${indexOfCurrentItem} \nCurrent Count: ${postItem.thumbsUp}');
    var oldItem = event.socialPostCreate;

    postItem = itemThumbsUp(postItem, event);

    List<PostItem> socialPosts = state.socialPosts;

    socialPosts[indexOfCurrentItem] = postItem;

    emit(PostState(status: PostApiStatus.success,
        socialPosts: socialPosts, hasReachedMax: false));

    String token = "";
    await LocalSharedPref().getToken().then((value) {
      token = value;
    });
    Map<String, dynamic> tokenDecoded = JWTHelper().decodeJwt(token);
    String userID = tokenDecoded[IDENTIFIER];

    SocialPostReactionRequest request = SocialPostReactionRequest(
        event.socialPostCreate.id, userID, false, event.isThumbsUp, false);
    var apiresponse = await api.socialPostReact(request);

    if (apiresponse is APIException) {

      state.socialPosts[indexOfCurrentItem] = oldItem;

      emit(state.copyWith(
        errorMessage: apiresponse.message,
        status: PostApiStatus.interactionFailed,
      ));

      emit(state.copyWith(
          status: PostApiStatus.success,
          posts: state.socialPosts
      ));

    } else {
      var result = apiresponse as ApiResponse;
      if (kDebugMode) {
        print("${result == null}");
      }
      if (apiresponse.message != null &&
          apiresponse.message!.contains("Unauthorized access")) {
        state.socialPosts[indexOfCurrentItem] = oldItem;

        emit(state.copyWith(
            status: PostApiStatus.success,
            posts: state.socialPosts
        ));

        emit(state.copyWith(
          status: PostApiStatus.authFailed,
        ));
      }
    }
  }

  PostItem itemLiked(PostItem postItem, SocialPostLikeEvent event, ) {
    postItem.like  = event.isLiked ? postItem.like + 1 : (postItem.like - 1) > 0 ? postItem.like - 1:0;
    postItem.isLiked = event.isLiked;
    if(postItem.isThumbsUp!){
      postItem.thumbsUp  = (postItem.thumbsUp - 1) > 0 ? postItem.thumbsUp - 1:0;
    }

    if(postItem.isApplauded!){
      postItem.applaud  = (postItem.applaud - 1) > 0 ? postItem.applaud - 1:0;
    }
    postItem.isThumbsUp = false;
    postItem.isApplauded = false;
    return postItem;
  }

  PostItem itemThumbsUp(PostItem postItem, SocialThumbsUpEvent event, ) {
    postItem.thumbsUp  = event.isThumbsUp ? postItem.thumbsUp + 1 : (postItem.thumbsUp - 1) > 0 ? postItem.thumbsUp - 1:0;
    postItem.isThumbsUp = event.isThumbsUp;
    if(postItem.isLiked!){
      postItem.like  = (postItem.like - 1) > 0 ? postItem.like - 1:0;
    }

    if(postItem.isApplauded!){
      postItem.applaud  = (postItem.applaud - 1) > 0 ? postItem.applaud - 1:0;
    }
    postItem.isLiked = false;
    postItem.isApplauded = false;
    return postItem;
  }

  PostItem itemAppluaded(PostItem postItem, SocialApplaudEvent event, ) {
    postItem.applaud  = event.isApplaud ? postItem.applaud + 1 : (postItem.applaud - 1) > 0 ? postItem.applaud - 1:0;
    postItem.isApplauded = event.isApplaud;

    if(postItem.isLiked!){
      postItem.like  = (postItem.like - 1) > 0 ? postItem.like - 1:0;
    }

    if(postItem.isThumbsUp!){
      postItem.thumbsUp  = (postItem.thumbsUp - 1) > 0 ? postItem.thumbsUp - 1:0;
    }
    postItem.isThumbsUp = false;
    postItem.isLiked = false;
    return postItem;
  }

}
