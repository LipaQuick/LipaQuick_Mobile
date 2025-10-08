import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:lipa_quick/core/managers/language/language_bloc.dart';
import 'package:lipa_quick/core/managers/onboarding/onboarding_bloc.dart';
import 'package:lipa_quick/core/models/language.dart';
import 'package:lipa_quick/core/models/onboarding.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/button.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/register/register.dart';
import '../../../gen/assets.gen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Assets.icon.lauchericon.image(height: 92.0),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: OutlinedButton(
              onPressed: () => showLanguageBottomSheet(context), // #2 Function call
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(8.0),
                backgroundColor: appGrey200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: BlocBuilder<LanguageBloc, LanguageState>(
                      builder: (context, state) {
                        return state.selectedLanguage.image!.image();
                      },
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: appGreen400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Assets.icon.onboarding.svg()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onBoarding,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32.0),
                  Button.filled(
                    onPressed: (){goToRegistrationPage(context);},
                    label: l10n.getStarted,
                  ),
                  const SizedBox(height: 8.0),
                  Button.outlined(
                    onPressed: (){gotoLoginPage(context);},
                    label: l10n.haveAccount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  gotoLoginPage(BuildContext context) {
    var onBoardingEvent = BlocProvider.of<OnBoardingBloc>(context);
    onBoardingEvent.add(OnBoardingCompleted(onBoarding: OnBoarding(true)));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage())
      , (Route<dynamic> route) => route.isFirst);
    //Navigator.pushNamed(context, LipaQuickAppRouteMap.login);
    //context.go(LipaQuickAppRouteMap.login);
  }

  goToRegistrationPage(BuildContext context) {
    var onBoardingEvent = BlocProvider.of<OnBoardingBloc>(context);
    onBoardingEvent.add(OnBoardingCompleted(onBoarding: OnBoarding(true)));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => RegisterPage())
        , (Route<dynamic> route) => route.isFirst);
    // Navigator.pushNamed(context, LipaQuickAppRouteMap.register);
    // context.go(LipaQuickAppRouteMap.register);

  }
}