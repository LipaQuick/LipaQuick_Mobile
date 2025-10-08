import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/address.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';

class AddressSearch extends StatefulWidget {
  Api? apiClient;
  String? endPoint;
  AddressDetails? seletedDetails;
  final Function(AddressDetails)? onChanged;
  TextEditingController controllers;

  AddressSearch({Key? key, this.endPoint, this.seletedDetails
    , this.onChanged, required this.controllers}) : super(key: key) {
    apiClient = Api();
  }

  @override
  State<StatefulWidget> createState() => AddressSearchState();
}

class AddressSearchState extends State<AddressSearch> {
  AddressDetails? seletected;

  var futureData;

  static String _displayStringForOption(AddressDetails option) => option.name!;
  List<AddressDetails>? addressModel;
  var outlineStyle = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)));


  @override
  void initState() {
    futureData =  widget.apiClient!.fetchAddress(endPoint: widget.endPoint
        , id: widget.seletedDetails == null
        ? '' : widget.seletedDetails!.id);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    if (widget.apiClient == null) {
      debugPrint('API Client is Error');
    }

    var inputDecoration = InputDecoration(
      border: outlineStyle,
      hintText: widget.endPoint,
    );

    return FutureBuilder<List<AddressDetails>?>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          addressModel = snapshot.data!;
          debugPrint('API Client ${addressModel!.length}');
          return Autocomplete<AddressDetails>(
            optionsBuilder: (TextEditingValue value) {
              if (value.text.isEmpty) {
                debugPrint('Auto Complete Text Empty');
                return List.empty();
              }
              return addressModel!
                  .where((element) => element.name!
                      .toLowerCase()
                      .contains(value.text.toLowerCase()))
                  .toList();
            },
            fieldViewBuilder: (BuildContext context,
                    TextEditingController controller,
                    FocusNode node,
                    Function onSubmit) =>
                TextFormField(
                  controller: controller,
                  focusNode: node,
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Please enter ${widget.endPoint}';
                    }
                  },
                  decoration: inputDecoration,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                  ),
            ),
            optionsViewBuilder: (BuildContext context, Function onSelect,
                Iterable<AddressDetails> dataList) {
              debugPrint('Building Autocomplete List: ${dataList.length}');
              return Material(
                child: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        AddressDetails d = dataList.elementAt(index);
                        return InkWell(
                            onTap: () => onSelect(d),
                            child: Text(d.name!,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: appSurfaceBlack)));
                      },
                    ),
                  ),
                ),
              );
            },
            onSelected: (value) => {print(value.name!), widget.onChanged!(value)},
            displayStringForOption: _displayStringForOption,
          );
        } else {
          return TextFormField(initialValue: 'Country with API');
        }
      },
    );
  }

  @override
  void dispose() {
    widget.apiClient!.dispose();
    super.dispose();
  }
}

class AddressOthers extends StatefulWidget {
  Api? apiClient;
  String? endPoint;
  AddressDetails? seletedDetails;
  final Function(AddressDetails)? onChanged;
  TextEditingController controllers;

  AddressOthers({Key? key, this.endPoint, required this.seletedDetails,required this.controllers, this.onChanged}) : super(key: key) {
    apiClient = Api();
  }

  @override
  State<StatefulWidget> createState() => AddressSearchStateOthers();
}

class AddressSearchStateOthers extends State<AddressOthers> {
  AddressDetails? seletected;

  static String _displayStringForOption(AddressDetails option) => option.name!;
  List<AddressDetails>? addressModel;
  late Future<List<AddressDetails>?> futureData;
  var outlineStyle = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)));



  @override
  void initState() {
    futureData =  widget.apiClient!.fetchAddress(endPoint: widget.endPoint, id: widget.seletedDetails!.id);
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    if (widget.apiClient == null) {
      debugPrint('API Client is Error');
    }

    var inputDecoration = InputDecoration(
      border: outlineStyle,
      hintText: widget.endPoint,
    );

    return FutureBuilder<List<AddressDetails>?>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          addressModel = snapshot.data!;
          debugPrint('API Client ${addressModel!.length}');
          return Autocomplete<AddressDetails>(
            optionsBuilder: (TextEditingValue value) {
              if (value.text.isEmpty) {
                debugPrint('Auto Complete Text Empty');
                return List.empty();
              }
              return addressModel!
                  .where((element) => element.name!
                      .toLowerCase()
                      .contains(value.text.toLowerCase()))
                  .toList();
            },
            fieldViewBuilder: (BuildContext context,
                    TextEditingController controller,
                    FocusNode node,
                    Function onSubmit) =>
                TextFormField(
                  controller: controller,
                  focusNode: node,
                  decoration: inputDecoration,
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Please enter ${widget.endPoint}';
                    }
                  },
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal, color: appSurfaceBlack
                  ),

            ),
            optionsViewBuilder: (BuildContext context, Function onSelect,
                Iterable<AddressDetails> dataList) {
              debugPrint('Building Autocomplete List: ${dataList.length}');
              return Material(
                child: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        AddressDetails d = dataList.elementAt(index);
                        return InkWell(
                            onTap: () => onSelect(d),
                            child: Text(d.name!,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: appSurfaceBlack)));
                      },
                    ),
                  ),
                ),
              );
            },
            onSelected: (value) => {print(value.name!)
              , if(widget.onChanged != null && value != seletected){widget.onChanged!(value)}},
            displayStringForOption: _displayStringForOption,
          );
        } else {
          return TextFormField(initialValue: 'Country with API');
        }
      },
    );
  }

  @override
  void dispose() {
    widget.apiClient!.dispose();
    super.dispose();
  }
}
