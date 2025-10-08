import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:lipa_quick/core/models/address.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/text_styles.dart';

class SelectState extends StatefulWidget {
  final ValueChanged<AddressDetails> onCountryChanged;
  final ValueChanged<AddressDetails> onStateChanged;
  final ValueChanged<AddressDetails> onCityChanged;
  final VoidCallback? onCountryTap;
  final VoidCallback? onStateTap;
  final VoidCallback? onCityTap;
  final TextStyle? style;
  final Color? dropdownColor;
  final InputDecoration decoration;
  final double spacing;
  final Api? apiClient;

  AddressDetails? defaultCountry;
  AddressDetails? defaultState;
  AddressDetails? defaultCity;

  SelectState(
      {Key? key,
      required this.onCountryChanged,
      required this.onStateChanged,
      required this.onCityChanged,
      this.decoration =
          const InputDecoration(contentPadding: EdgeInsets.all(0.0)),
      this.spacing = 0.0,
      this.style,
      this.dropdownColor,
      this.onCountryTap,
      this.onStateTap,
      this.onCityTap,
      this.apiClient,
      this.defaultCountry, this.defaultState, this.defaultCity})
      : super(key: key);

  @override
  _SelectStateState createState() => _SelectStateState();
}

class _SelectStateState extends State<SelectState> {
  List<AddressDetails> _cities = [AddressDetails.init('0', "Choose City")];
  List<AddressDetails> _country = [AddressDetails.init('0', "Choose Country")];
  List<AddressDetails> _states = [
    AddressDetails.init('0', "Choose State/Province")
  ];

  AddressDetails? _selectedCity = AddressDetails.init('0', "Choose City");
  AddressDetails? _selectedCountry = AddressDetails.init('0', "Choose Country");
  AddressDetails? _selectedState =
      AddressDetails.init('0', "Choose State/Province");
  var responses;

  @override
  void initState() {
    getCounty();
    super.initState();
  }

  Future getCounty() async {
    var country = await widget.apiClient?.fetchAddress(endPoint: 'Country');
    if (country != null && country.isNotEmpty) {
      if (!mounted) return;
      debugPrint('Mounted and list items: ${country.length}');
      _country.addAll(country);
      setState(() {
        _country;
        if(widget.defaultCountry != null){
          for(AddressDetails details in _country){
            if(details.name!.toLowerCase() == widget.defaultCountry!.name!.toLowerCase()){
              _selectedCountry = details;
              _onSelectedCountry(_selectedCountry!);
              break;
            }
          }
        }
      });
    }
    return _country;
  }

  Future getState() async {
    var states = await widget.apiClient
        ?.fetchAddress(endPoint: 'State', id: _selectedCountry!.id);
    if (states != null) {
      if (!mounted) return;
      if(_states.isNotEmpty){
        _states.clear();
      }
      _states.addAll(states);
      setState(() {
        _states;
        if(widget.defaultState != null){
          for(AddressDetails details in _states){
            if(details.name!.toLowerCase() == widget.defaultState!.name!.toLowerCase()){
              print('State Selected ${widget.defaultState!.name!.toLowerCase()} == ${details.name!.toLowerCase()}');
              _selectedState = details;
              break;
            }
          }
          _onSelectedState(_selectedState!);
        }
      });
    }
    return _states;
  }

  Future getCity() async {
    var cities = await widget.apiClient
        ?.fetchAddress(endPoint: 'City', id: _selectedState!.id);
    if (cities != null) {
      if (!mounted) return;
      if(_cities.isNotEmpty){
        _cities.clear();
      }
      _cities.addAll(cities);
      setState(() {
        _cities;
        if(widget.defaultCity != null){
          for(AddressDetails details in _cities){
            if(details.name!.toLowerCase() == widget.defaultCity!.name!.toLowerCase()){
              print('City Selected ${widget.defaultCity!.name!.toLowerCase()} == ${details.name!.toLowerCase()}');
              _selectedCity = details;
              break;
            }
          }
          _onSelectedCity(_selectedCity!);
        }
      });
    }
    return _cities;
  }

  void _onSelectedCountry(AddressDetails value) {
    if (!mounted) return;
    setState(() {
      if(widget.defaultState == null){
        _selectedState = AddressDetails.init('0', 'Choose State/Province');
        _states = [AddressDetails.init('0', 'Choose State/Province')];
      }
      _selectedCountry = value;
      widget.onCountryChanged(value);
      getState();
    });
  }

  void _onSelectedState(AddressDetails value) {
    if (!mounted) return;
    setState(() {
      if(widget.defaultCity == null) {
        _selectedCity = AddressDetails.init('0', 'Choose City');
        _cities = [AddressDetails.init('0', 'Choose City')];
      }
      _selectedState = value;
      this.widget.onStateChanged(value);
      getCity();
    });
  }

  void _onSelectedCity(AddressDetails value) {
    if (!mounted) return;
    setState(() {
      _selectedCity = value;
      this.widget.onCityChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DropdownSearch<AddressDetails>(
          items: _country,
          dropdownBuilder: (context, selectedItem) {
            return Container(
                child: selectedItem != null
                    ? Text(
                        selectedItem.name!,
                        style: const TextStyle(
                          color: appSurfaceBlack,
                          fontSize: 11,
                        ),
                      )
                    : null);
          },
          popupProps: PopupProps.bottomSheet(
            title: TitleWidget(),
            bottomSheetProps: const BottomSheetProps(
                elevation: 10,
                backgroundColor: appGrey100,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)))),
            itemBuilder:
                (BuildContext context, AddressDetails item, bool selected) {
              debugPrint('Item: ${item.name}, Selected: $selected');
              return ItemWidget(item, selectedItem: _selectedCountry);
            },
            disabledItemFn: (value) => value.name == 'Choose Country',
            showSearchBox: false,
            searchFieldProps: TextFieldProps(autofocus: true),
            //showSelectedItems: true,
          ),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
                labelStyle: TextStyle(color: appGreen400, fontSize: 16),
                label: Text('Choose Country'),
                contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: appSurfaceBlack)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: appSurfaceBlack)),
                floatingLabelBehavior: FloatingLabelBehavior.auto),
          ),
          onChanged: (value) => _onSelectedCountry(value!),
          selectedItem: _selectedCountry ?? _selectedCountry,
        ),
        SizedBox(
          height: widget.spacing,
        ),
        DropdownSearch<AddressDetails>(
          items: _states,
          dropdownBuilder: (context, selectedItem) {
            return Container(
                child: selectedItem != null
                    ? Text(
                        selectedItem.name!,
                        style: TextStyle(
                          color: appSurfaceBlack,
                          fontSize: 11,
                        ),
                      )
                    : null);
          },
          popupProps: PopupProps.bottomSheet(
            title: TitleWidget(),
            bottomSheetProps: const BottomSheetProps(
                elevation: 10,
                backgroundColor: appGrey100,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)))),
            itemBuilder:
                (BuildContext context, AddressDetails item, bool selected) {
              debugPrint('Item: ${item.name}, Selected: $selected');
              return ItemWidget(item, selectedItem: _selectedState);
            },
            disabledItemFn: (value) => value.name == 'Choose State',
            showSearchBox: false,
            searchFieldProps: TextFieldProps(autofocus: true),
            //showSelectedItems: true,
          ),
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
                labelStyle: TextStyle(color: appGreen400, fontSize: 16),
                label: Text('Choose  State/Province'),
                contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: appSurfaceBlack)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color:appSurfaceBlack)),
                floatingLabelBehavior: FloatingLabelBehavior.auto),
          ),
          onChanged: (value) => _onSelectedState(value!),
        ),
        SizedBox(
          height: widget.spacing,
        ),
        DropdownSearch<AddressDetails>(
          items: _cities,
          asyncItems: (String filter) => getData(filter),
          dropdownBuilder: (context, selectedItem) {
            return Container(
                child: selectedItem != null
                    ? Text(
                        selectedItem.name!,
                        style: TextStyle(
                          color: appSurfaceBlack,
                          fontSize: 11,
                        ),
                      )
                    : null);
          },
          popupProps: PopupProps.bottomSheet(
            title: TitleWidget(),
            bottomSheetProps: const BottomSheetProps(
                elevation: 10,
                backgroundColor: appGrey100,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)))),
            itemBuilder: (BuildContext context, AddressDetails item, bool selected) {
              debugPrint('Item: ${item.name}, Selected: $selected');
              return ItemWidget(item, selectedItem: _selectedCity);
            },
            disabledItemFn: (value) => value.name == 'Choose City',
            showSearchBox: _cities.length > 10,
            searchFieldProps: TextFieldProps(autofocus: true),
            //showSelectedItems: true,
          ),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
                labelStyle: TextStyle(color: appGreen400, fontSize: 14),
                label: Text('Choose City'),
                contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: appSurfaceBlack)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: appSurfaceBlack)),
                floatingLabelBehavior: FloatingLabelBehavior.auto),
          ),
          onChanged: (value) => _onSelectedCity(value!),
        ),
      ],
    );
  }

  Future<List<AddressDetails>> getData(String filter) async{
    debugPrint('$filter');
    if(filter.isEmpty){
      return [];
    }
    return _cities.where((element) => element.name!.toLowerCase().contains(filter)).toList();
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget(
    this.currentItem, {
    super.key,
    required AddressDetails? selectedItem,
  }) : _selectedItem = selectedItem;

  final AddressDetails? _selectedItem, currentItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "${currentItem!.name}",
              textAlign: TextAlign.start,
              style: regionSelection,
            ),
          ),
          color: currentItem!.name == _selectedItem!.name!
              ? appGreen100
              : appSurfaceWhite,
        ));
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "",
                textAlign: TextAlign.start,
                style: InputTitleStyle,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: appGreen400,
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}
