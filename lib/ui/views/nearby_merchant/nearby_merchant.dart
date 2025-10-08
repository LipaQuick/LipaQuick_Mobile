import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/nearby/merchant_nearby_model.dart';
import 'package:lipa_quick/core/view_models/merchant_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/views/register/register.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class NearByMerchantScreen extends StatefulWidget {
  const NearByMerchantScreen({super.key});

  @override
  State<NearByMerchantScreen> createState() => _NearByMerchantScreenState();
}

class _NearByMerchantScreenState extends State<NearByMerchantScreen> {
  MerchantViewModel locations = locator<MerchantViewModel>();
  final Map<String, Marker> _markers = {};

  GoogleMapController? _controller;

  Future<void> _onMapCreated(AsyncSnapshot<dynamic> snapshot) async {
    if (snapshot.hasData) {
      if (snapshot.data is APIException) {
        var data = snapshot.data as APIException;
        print(data.toString());
        CustomDialog(DialogType.FAILURE).buildAndShowDialog(
            context: context,
            title: AppLocalizations.of(context)!.merchat_title,
            message: data.message!,
            buttonPositive: 'OK',
            onPositivePressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pop();
            });
        return;
      }
      final googleOffices = (snapshot.data as NearByResponse).data;
      _markers.clear();
      for (final office in googleOffices!) {
        var latLng = office.latLng!.split(',');
        var merchantLocation = LatLng(
            double.parse(latLng[0].trim()), double.parse(latLng[1].trim()));
        final marker = Marker(
          markerId: MarkerId(office.id!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: merchantLocation,
          infoWindow: InfoWindow(
              title: 'Merchant: ${office.name}',
              snippet:
                  '${(office.distance!).toStringAsFixed(2)} km away.',
              onTap: () {
                openMap(context, locations.currentDeviceLocation as Position,
                    merchantLocation);
              }),
        );
        _markers.putIfAbsent(marker.markerId.value, () {
          return marker;
        });
      }
    }
  }

  Future<void> openMap(
      BuildContext context, Position source, LatLng destinaiton) async {
    String url = '';
    String urlAppleMaps = '';
    if (Platform.isAndroid) {
      url =
          'https://www.google.com/maps/dir/?api=1&origin=${source.latitude},${source.longitude}'
          '&destination=${destinaiton.latitude},${destinaiton.longitude}&directionsmode=driving';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        CustomDialog(DialogType.FAILURE).buildAndShowDialog(
            context: context,
            title: AppLocalizations.of(context)!.error_hint,
            message:
                'Cannot launch google maps. Please you have working browser and google maps installed.',
            onPositivePressed: () {
              Navigator.of(context).pop();
            },
            buttonPositive: 'OK');
      }
    }
    else {
      // CustomDialog(DialogType.FAILURE).buildAndShowDialog(
      //   context: context,
      //   title: AppLocalizations.of(context)!.nav_merchant,
      //   message:
      //       'Cannot launch google maps. Please you have working browser and google maps installed.',
      //   onPositivePressed: () {
      //     launchGoogleMaps(source, destinaiton);
      //   },
      //   onNegativePressed: () {
      //     launchAppleMaps(source, destinaiton);
      //   },
      //   buttonPositive: 'Google Maps',
      //   buttonNegative: 'Apple Maps',
      // );
      //Show BottomSheet here
      showMoreActions(source, destinaiton);

    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: locations.getNearByMerchant(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                appBar: AppTheme.getAppBar(
                    context: context,
                    title: '',
                    subTitle: '',
                    enableBack: true),
                body: const Center(
                  child: CircularProgressIndicator(),
                ));
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data is APIException) {
              if ((snapshot.data as APIException).apiError ==
                  APIError.PERMISSION_UNAVAILABLE) {
                return EmptyViewFailedWidget(
                  title: 'Please allow LipaQuick to access device Location',
                  message:
                      'LipaQuick needs the location to search nearby merchant around you.\n${(snapshot.data as APIException).message!}',
                  icon: Icons.explore_off_outlined,
                  buttonHint: 'OK',
                  callback: () {
                    Navigator.of(context).pop();
                  },
                );
              } else {
                _onMapCreated(snapshot);
                return Scaffold(
                  appBar: AppTheme.getAppBar(
                      context: context,
                      title: '',
                      subTitle: '',
                      enableBack: true),
                  body: GoogleMap(
                    mapType: MapType.normal,
                    onMapCreated: (controller) {
                      _controller = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: locations.currentDeviceLocation != null
                          ? LatLng(
                              (locations.currentDeviceLocation as Position)
                                  .latitude,
                              (locations.currentDeviceLocation as Position)
                                  .longitude)
                          : const LatLng(0, 0),
                      zoom: 1,
                    ),
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    markers: _markers.values.toSet(),
                  ),
                );
              }
            } else if (snapshot.data is NearByResponse) {
              _onMapCreated(snapshot);
              return Scaffold(
                appBar: AppTheme.getAppBar(
                    context: context,
                    title: '',
                    subTitle: '',
                    enableBack: true),
                body: GoogleMap(
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    _controller = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: locations.currentDeviceLocation != null
                        ? LatLng(
                            (locations.currentDeviceLocation as Position)
                                .latitude,
                            (locations.currentDeviceLocation as Position)
                                .longitude)
                        : const LatLng(0, 0),
                    zoom: 14,
                  ),
                  markers: _markers.values.toSet(),
                ),
              );
            } else {
              return EmptyViewFailedWidget(
                title: 'Nearby Merchant',
                message: 'message',
                icon: Icons.error_outlined,
                buttonHint: 'GO BACK',
                callback: () {
                  Navigator.of(context).pop();
                },
              );
            }
          } else {
            return Center(
              child: Text('Other State o${snapshot.connectionState.name}'),
            );
          }
        });
  }

  Future<void> showMoreActions(Position source, LatLng destination) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose: ',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 16.0),
              Wrap(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.apple_outlined,
                    ),
                    title: Text('Apple Maps'),
                    onTap: () {
                      Navigator.of(context).pop();
                      launchAppleMaps(source, destination);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.map_sharp,
                    ),
                    title: Text('Google Maps'),
                    onTap: (){
                      Navigator.of(context).pop();
                      launchGoogleMaps(source, destination);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> launchGoogleMaps(
      Position source, LatLng destination) async {
    var url = 'comgooglemaps://?saddr=${source.latitude},${source.longitude}'
        '&daddr=${destination.latitude},${destination.longitude}&directionsmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }else{
      showToast(context, 'Google Maps is not installed on your device.');
    }
  }

  Future<void> launchAppleMaps(
      Position source, LatLng destinaiton) async {
    var urlAppleMaps =
        'https://maps.apple.com/?saddr=${source.latitude},${source.longitude}'
        '&daddr=${destinaiton.latitude},${destinaiton.longitude}&dirflg=d';
    if (await canLaunchUrl(Uri.parse(urlAppleMaps))) {
      await launchUrl(Uri.parse(urlAppleMaps));
    }else{
      showToast(context, 'Apple Maps is not installed on your device.');
    }
  }

  showToast(BuildContext context, String msg) {
    Widget toast = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.grey.shade500,
          ),
          child: Center(
              child: Text(
                msg,
                maxLines: 3,
                textAlign: TextAlign.center,
              )),
        ));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: toast, duration: Duration(seconds: 2)));
  }
}
