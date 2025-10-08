import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/managers/language/language_bloc.dart';
import 'package:lipa_quick/core/managers/pin_managers/pin_bloc.dart';
import 'package:lipa_quick/core/models/language.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/views/app_lock_pin/create_lock_pin.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false; // Default notification setting
  bool _twoFactorEnabled = false; // Default two Factor settings
  late AppPinBloc pinBloc;

  // Function to update the notification setting
  Future<void> _updateNotifications(bool value) async {
    debugPrint('_updateNotifications: ${value}');
    await LocalSharedPref().setNotification(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  // Function to update the notification setting
  Future<void> _updateTwoFactor(bool value) async {
    debugPrint('_updateTwoFactor: ${value}');
    //await LocalSharedPref().setTwoFactor(value);
    if(value){
      pinBloc.add(EnableAppLock());
      AppLock.of(context)!.setEnabled(true);
    }else{
      pinBloc.add(DisableAppLock());
      AppLock.of(context)!.setEnabled(false);
    }

  }



  @override
  void initState() {
    super.initState();
    //trigger language bloc
    context.read<LanguageBloc>().add(GetLanguage());
    pinBloc = context.read<AppPinBloc>();
    pinBloc.add(AppPinStatus());
  }


  void showLanguageBottomSheet(BuildContext context) {
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
                AppLocalizations.of(context)!.choose_language,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, state) {
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: LanguageModel.values.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          // # 1
                          // Trigger the ChangeLanguage event
                          context.read<LanguageBloc>().add(
                            ChangeLanguage(
                              selectedLanguage: LanguageModel.values[index],
                            ),
                          );
                          Future.delayed(const Duration(milliseconds: 300))
                              .then((value) => Navigator.of(context).pop());
                        },
                        leading: ClipOval(
                          child: LanguageModel.values[index].image!.image(
                            height: 32.0,
                            width: 32.0,
                          ),
                        ),
                        title: Text(LanguageModel.values[index].text!),
                        trailing:
                        LanguageModel.values[index] == state.selectedLanguage
                            ? Icon(
                          Icons.check_circle_rounded,
                          color: ColorsLib.primary,
                        )
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: LanguageModel.values[index] == state.selectedLanguage
                              ? BorderSide(color: ColorsLib.primary, width: 1.5)
                              : BorderSide(color: Colors.grey[300]!),
                        ),
                        tileColor:
                        LanguageModel.values[index] == state.selectedLanguage
                            ? ColorsLib.primary.withOpacity(0.05)
                            : null,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 16.0);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppTheme.getAppBar(context: context, title: l10n.settings, subTitle: '', enableBack: true),
      body: BlocBuilder<AppPinBloc, PinState>(
        buildWhen: (previousState, currentState){
          debugPrint(currentState.toString());
          if(currentState is AppLockNotCreated){
            //Open Pin Create Screen
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AppLockPinWidget(pinAction: PinAction.CREATE_PIN)));
            return false;
          }
          return true;
        },
        builder: (context, state){
          return FutureBuilder(
              future: getSettings(),
              builder: (context, snapshot) {
                return ListView(
                  children: [
                    ListTile(
                      title: BlocBuilder<LanguageBloc, LanguageState>(
                        builder: (context, state) {
                          return Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(
                                    l10n.language,
                                    style: GoogleFonts.poppins(fontSize: 21),
                                  )
                              ),
                              ClipOval(
                                child:
                                state.selectedLanguage.image!.image(height: 30),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                  child: Text(state.selectedLanguage.text!,
                                      style: GoogleFonts.poppins(fontSize: 17))
                              )
                            ],
                          );
                        },
                      ),
                      onTap: () {
                        showLanguageBottomSheet(context);
                      },
                    ),
                    Divider(),
                    ListTile(
                      title: Text(l10n.notification,  style: GoogleFonts.poppins(fontSize: 21)),
                      trailing: Switch.adaptive(
                        value: _notificationsEnabled,
                        onChanged: _updateNotifications,
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(l10n.enable_app_lock,  style: GoogleFonts.poppins(fontSize: 21)),
                      trailing: Switch.adaptive(
                        value: _twoFactorEnabled,
                        onChanged: _updateTwoFactor,
                      ),
                    ),
                    Divider(), // Add more settings options here
                  ],
                );
              });
        },
      ),
      );
  }

  Future<void> getSettings() async {
    _notificationsEnabled = await LocalSharedPref().getNotification();
    _twoFactorEnabled = (pinBloc.state is AppPinEnabled)
        ?(pinBloc.state as AppPinEnabled).enabled:false;
  }
}
