import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_state.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';
import 'package:lipa_quick/core/models/profile/profile_list_reponse.dart';
import 'package:lipa_quick/core/services/blocs/profile_bloc.dart';
import 'package:lipa_quick/core/services/events/profile_events.dart';
import 'package:lipa_quick/core/services/states/app_states.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'dart:async';

import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/views/nearby_merchant/nearby_merchant.dart'; // For async data fetching

class MapsLocationWidget extends StatelessWidget {

  MapsLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => ProfileBloc(),
        child: UserLocationWidget(),
      ),
    );
  }
}

class UserLocationWidget extends StatefulWidget {
  UserLocationWidget();

  @override
  _UserLocationWidgetState createState() => _UserLocationWidgetState();
}

class _UserLocationWidgetState extends State<UserLocationWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentLocation;
  bool _isLocationUpdated = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    context.read<ProfileBloc>()
        .add(ProfileFetch());

    return BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if(state.status == ApiStatus.success){
            if(state.profileDetailsResponse != null
                && state.profileDetailsResponse!.role != 'Merchant'){
              Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const NearByMerchantScreen()));
            }
          }
        },
        child: Scaffold(
          appBar: AppTheme.getAppBar(context: context, title: '', subTitle: '', enableBack: true),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.status == ApiStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.status == ApiStatus.success) {
                final user = state.profileDetailsResponse;
                return Column(
                  children: [
                    ListTile(
                      title: Text("Name: ${user!.firstName.toUpperCase()}", style: GoogleFonts.poppins(fontWeight: FontWeight.w700),),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email: ${user.email}"),
                          Text("Address: ${user.street}, ${user.city}, ${user.state}"),
                        ],
                      ),
                    ),
                    if (user.getUserLatLng() != null)
                      Expanded(
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: user.getUserLatLng()!,
                            zoom: 18.0,
                          ),
                          scrollGesturesEnabled: false,
                          markers: {
                            Marker(
                              markerId: MarkerId('user_location'),
                              position: user.getUserLatLng()!,
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                            ),
                          },
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                      )
                    else
                      const Expanded(
                        child: Stack(
                          children: [
                            EmptyViewFailedWidget(title: 'Location not updated'
                                , message: 'Your establishment location has not been updated. Please contact support for the same.'
                                , icon: Icons.location_disabled_rounded)
                          ],
                        ),
                      ),
                  ],
                );
              } else if (state.status == ApiStatus.failure) {
                return Center(child: Text("Error fetching user details"));
              }
              return Center(child: Text("Unknown state"));
            },
          ),
        ),
    );
  }
}
