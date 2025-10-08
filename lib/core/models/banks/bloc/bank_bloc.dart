import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/global/Application.dart';
import 'package:lipa_quick/core/models/banks/bank_details.dart';
import 'package:lipa_quick/core/models/banks/bank_response.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_event.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/request_header_dto.dart';
import 'package:lipa_quick/core/services/device_details.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:stream_transform/stream_transform.dart';


const _postLimit = 20;
const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class BankBloc extends Bloc<ApiEvent, BankState> {
  BankBloc({required this.httpClient}) : super(const BankState()) {
    on<BanksFetched>(
      _onPostFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final http.Client httpClient;

  Future<void> _onPostFetched(
      BanksFetched event,
      Emitter<BankState> emit,
      ) async {
    if (state.hasReachedMax) {
      if (kDebugMode) {
        print("Limit has reached");
      }
      return;
    }
    try {
      if (state.status == ApiStatus.initial) {
        if (kDebugMode) {
          print("Initials Bank");
        }
        final banks = await _fetchBanks();
        return emit(
          state.copyWith(
            status: ApiStatus.success,
            posts: banks,
            hasReachedMax: false,
          ),
        );
      }
      final posts = await _fetchBanks(state.banks.length);
      posts!.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
        state.copyWith(
          status: ApiStatus.success,
          posts: List.of(state.banks)..addAll(posts),
          hasReachedMax: false,
        ),
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(status: ApiStatus.failure));
    }
  }

  Future<dynamic> _fetchBanks([int startIndex = 0]) async {
    final url = Uri.parse('${ApplicationData().API_URL}/banks');
    String token = "";
    await LocalSharedPref().getToken().then((value) {
      token = value;
    });
    var deviceData = <String, dynamic>{};
    await DeviceInfo().getDeviceInfo().then((value) {
      deviceData = value;
    });
    RequestHeaderDto requestHeaderDto =
    RequestHeaderDto(deviceData['Source'], deviceData['Device'], deviceData['Version']);
    String headerEn = encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
    // Get user profile for id
    print('Calling API '+token);
    var response = await httpClient.get(url, headers: {
      "content-type" : "application/json",
      "accept" : "application/json",
      "User-Agent": headerEn,
      'Authorization': 'Bearer $token',
    });

    // final response = await httpClient.get(
    //   Uri.https(
    //     'jsonplaceholder.typicode.com',
    //     '/posts',
    //     <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'},
    //   ),
    // );
    print(response.body);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final bankListResponse = BankListResponse.fromJson(body);

      if(bankListResponse.status!){
        return bankListResponse.data!;
      }else {
        throw Exception(bankListResponse.message!);
      }
    }
  }
}