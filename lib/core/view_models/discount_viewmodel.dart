import 'package:intl/intl.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/discount/discount_model.dart';
import 'package:lipa_quick/core/models/payment/payment.dart';
import 'package:lipa_quick/core/models/payment/recent_transaction.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/view_models/base_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/main.dart';

const int PAGE_SIZE = 20;

class DiscountViewModel extends BaseModel{
  List<DiscountItems> _items = [];
  int _currentPage = 0;
  int totalPageSize  = 0;
  bool isLoading = false;
  final Api _api = locator<Api>();
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');


  DiscountViewModel();

  Future<dynamic> getDiscounts(String? receiversId, int? amount) async {
    isLoading = true;
    //Create Discount request
    var discount = DiscountRequest(userId: receiversId, amount: amount?.toInt());
    // Call your API here to fetch items with pagination and date range parameters
    dynamic fetchedItems = await _api.getAllDiscounts(discount);
    if(fetchedItems is APIException){
      return fetchedItems;
    }else if(fetchedItems is DiscountResponse){
      if(fetchedItems.status!){
        //totalPageSize = fetchedItems.total!;
        if(_currentPage == 0){
          _items = [];
        }
        _items.addAll(fetchedItems.data!);
      }
    }
    isLoading = false;
    return fetchedItems;
  }


  int getSavedAmount(int amount, DiscountItems? currentSelectedDiscount) {
    if (currentSelectedDiscount == null) {
      return amount;
    }
    if (currentSelectedDiscount.amountPercentageActive!) {
      return (amount * currentSelectedDiscount.amountPercentage!) ~/
          100;
    } else {
      return (amount -  currentSelectedDiscount.flatAmount!);
    }
  }



  Future<dynamic> checkServiceChargeAndCommission({int? amount, PaymentRequest? paymentMode}) async{
    isLoading = true;
    //Create Discount request
    var discount = DiscountRequest();
    if(paymentMode!.discountItem != null){
      amount = getSavedAmount(amount!, paymentMode.discountItem);
    }
    Map<String, dynamic> serviceChargeAndCommission = {
      "amount": amount!,
      "serviceType": paymentMode!.paymentMode,
    };
    // Call your API here to fetch items with pagination and date range parameters
    dynamic fetchedItems = await _api.getTransactionSummary(serviceChargeAndCommission);
    if(fetchedItems is APIException){
      return fetchedItems;
    }else if(fetchedItems is DiscountResponse){
      if(fetchedItems.status!){
        //totalPageSize = fetchedItems.total!;
        if(_currentPage == 0){
          _items = [];
        }
        _items.addAll(fetchedItems.data!);
      }
    }
    isLoading = false;
    return fetchedItems;
  }
}