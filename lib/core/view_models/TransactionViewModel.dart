import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/payment/payment_status_response.dart';
import 'package:lipa_quick/core/models/payment/recent_transaction.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/view_models/base_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/main.dart';

const int PAGE_SIZE = 20;

class TransactionViewModel extends BaseModel{
  List<RecentTransaction> _items = [];
  int _currentPage = 0;
  int totalPageSize  = 0;
  bool isLoading = false;
  bool _hasMoreData = true;
  DateTime? _startDate;
  DateTime? _endDate;
  final Api _api = locator<Api>();
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');


  TransactionViewModel();

  Future<dynamic> getItems(DateTime startDate, DateTime endDate, [int? page]) async {
    isLoading = true;
    if(_startDate != null && _endDate != null){
      print('Date Changed');
      if(_startDate != startDate && _endDate != endDate){
        print('Date Changed');
        _items = [];
      }
    }
    _startDate = startDate;
    _endDate = endDate;
    // Call your API here to fetch items with pagination and date range parameters
    dynamic fetchedItems = await _api.getRecentTransaction(page ?? _currentPage,PAGE_SIZE
        , dateFormat.format(startDate)
        , dateFormat.format(endDate));
    if(fetchedItems is APIException){
      return fetchedItems;
    }else if(fetchedItems is RecentTransactionResponse){
      // debugPrint("getItems Received Transactions");
      if(fetchedItems.status!){
        totalPageSize = fetchedItems.total!;
        // debugPrint("getItems Total Fetched Size: $totalPageSize");
        if(_currentPage == 0){
          _items = [];
        }

        _items.addAll(fetchedItems.data!);
      }
      isLoading = false;
      // debugPrint("getItems Returning Fetched Items: ${fetchedItems.toString()}");
      return _items;
    }
    isLoading = false;
    return _items;
  }

  Future<dynamic> refreshItems() async {
    _items.clear();
    _currentPage = 0;
    _hasMoreData = true;
    return await getItems(_startDate!, _endDate!, _currentPage);
  }

  Future<dynamic> loadMoreItems() async {
    if (_hasMoreData && !isLoading) {
      _currentPage++;
      return await getItems(_startDate!, _endDate!, _currentPage);
    }
  }

  Future<dynamic>  getTransactionStatus(String? id) async {
    isLoading = true;

    dynamic fetchedItems = await _api.getTransactionStatus(id!);
    if(fetchedItems is APIException){
      isLoading = false;
      return fetchedItems;
    }else if(fetchedItems is TransactionResponse){
      // debugPrint("getItems Received Transactions");
      return fetchedItems.data;
      }

    isLoading = false;
    return null;
  }
}