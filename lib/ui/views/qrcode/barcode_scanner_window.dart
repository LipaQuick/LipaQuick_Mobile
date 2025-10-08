import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/payment/qr_payment_model.dart';
import 'package:lipa_quick/core/services/blocs/chat_bloc.dart';
import 'package:lipa_quick/core/services/events/chat_events.dart';
import 'package:lipa_quick/core/services/states/chat_state.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/views/payment/payment_screen.dart';
import 'package:lipa_quick/ui/views/qrcode/border_painter.dart';
import 'package:lipa_quick/ui/views/qrcode/scanner_error_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BarcodePage extends StatelessWidget{

  BarcodePage({super.key});

  @override
  Widget build(BuildContext context) {
    //context.read<SignalRBloc>().add(LoadInitialMessagesEvent());
    return Scaffold(
        body: BlocProvider(
            create: (_) => SignalRBloc(chats: RecentChats.name()),
            child: BarcodeScannerWithScanWindow()));
  }
}

class BarcodeScannerWithScanWindow extends StatefulWidget {
  const BarcodeScannerWithScanWindow({Key? key}) : super(key: key);

  @override
  _BarcodeScannerWithScanWindowState createState() =>
      _BarcodeScannerWithScanWindowState();
}

class _BarcodeScannerWithScanWindowState
    extends State<BarcodeScannerWithScanWindow> with WidgetsBindingObserver {
  late MobileScannerController controller = MobileScannerController(
    autoStart: true,
    torchEnabled: false,
    useNewCameraSelector: true
  );
  Barcode? barcode;
  BarcodeCapture? capture;

  Future<void> onDetect(BarcodeCapture barcode) async {
    //print('onDetect');
    //print('Display Value: ${barcode.barcodes.first.displayValue}');
    try{
      QrPaymentModel model = QrPaymentModel.fromJson(jsonDecode(barcode.barcodes.first.displayValue!));
      if(model.userDetails!.identityStatus! == 'Not Verified'){
        controller.stop();
        CustomDialog(DialogType.FAILURE).buildAndShowDialog(
            context: context,
            title: AppLocalizations.of(context)!.un_verified_account,
            message: AppLocalizations.of(context)!.un_verified_account_msg,
            onPositivePressed: () {
              //controller.start();
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pop();
            },
            buttonPositive: AppLocalizations.of(context)!.button_ok);
      }
      else{
        //TODO - Send to payment page.
        // Create a instance of the data being passed.
        //
        await Future.delayed(Duration(microseconds: 300));
        controller.stop();
        //debuf(model.userDetails!.toJson());
        context.read<SignalRBloc>().add(SignalRFindUserDetailsEvent(
            model.userDetails!.phoneNumber
        ));

      }
    }catch(e){
      print(e);
      controller.stop();
      CustomDialog(DialogType.INFO).buildAndShowDialog(
          context: context,
          title: '',
          message: barcode.barcodes.first.displayValue,
          onPositivePressed: () {
            //controller.start();
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop();
          },
          buttonPositive: AppLocalizations.of(context)!.button_ok);
    }

    capture = barcode;
    setState(() => this.barcode = barcode.barcodes.first);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
      // Restart the scanner when the app is resumed.
      // Don't forget to resume listening to the barcode events.

        unawaited(controller.start());
        break;
      case AppLifecycleState.inactive:
      // Stop the scanner when the app is paused.
      // Also stop the barcode events subscription.
        //unawaited(_subscription?.cancel());
        //_subscription = null;
        unawaited(controller.stop());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Size.copy(MediaQuery.of(context).size);
    try{
      controller.setZoomScale(0.5);
    }catch(e){
    }
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: size.height / 3,
      height: size.height / 3,
      // width: 500,
      // height: 500,
    );
    return BlocListener<SignalRBloc, SignalRState>(
      listener: (context, state) {
        if (state is SignalRUserState) {
          //controller.stop();
          debugPrint('Switching to Payment Page');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PaymentPage(
                    true,
                    contact: state.response,
                  )));
        }
      }, child:  BlocBuilder<SignalRBloc, SignalRState>(
      builder: (context, state){
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, 100),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Container(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Icon(Icons.navigate_before,size: 40,color: Colors.black,),
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(AppLocalizations.of(context)!.scan_qrcode_title,style: TextStyle(fontSize: 30,color: Colors.black),),
                      Icon(Icons.navigate_before,color: Colors.transparent,),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Builder(
            builder: (context) {
              return Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Align(
                      child:  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: CustomPaint(
                              painter: BoxBorderCamera(color: appGreen400),
                              child: Padding(
                                padding: EdgeInsets.all(11),
                                child: SizedBox(
                                  width: size.height / 3,
                                  height: size.height / 3,
                                  // width: 400,
                                  // height: 400,
                                  child:  MobileScanner(
                                    fit: BoxFit.fill,
                                    controller: controller,
                                    errorBuilder: (context, error, child) {
                                      return ScannerErrorWidget(error: error);
                                    },
                                    onDetect: onDetect,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              AppLocalizations.of(context)!.adjust_qrcode_msg,
                              overflow: TextOverflow.fade,
                              style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(color: Colors.black, fontSize: 21)
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    if (barcode != null &&
                        barcode?.corners != null)
                      CustomPaint(
                          painter: ScannerOverlay(scanWindow)
                      ),
                    // CustomPaint(
                    //   painter: ScannerOverlay(scanWindow),
                    // ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        height: 100,
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircleAvatar(
                              backgroundColor:appGreen400,
                              radius: 30,
                              child: Center(
                                child: IconButton(
                                  color: Colors.white,
                                  icon: ValueListenableBuilder(
                                    valueListenable: controller,
                                    builder: (context, state, child) {
                                      if (state == null) {
                                        return const Icon(
                                          Icons.flash_off,
                                          color: Colors.white,
                                        );
                                      }
                                      switch (state.torchState) {
                                        case TorchState.off:
                                          return const Icon(
                                            Icons.flash_off,
                                            color: Colors.white,
                                          );
                                        case TorchState.on:
                                          return const Icon(
                                            Icons.flash_on,
                                            color: Colors.yellow,
                                          );
                                        case TorchState.auto:
                                        // TODO: Handle this case.
                                          return const Icon(Icons.flash_auto, color: Colors.white,);
                                          break;
                                        case TorchState.unavailable:
                                          return const Icon(
                                            Icons.no_flash,
                                            color: Colors.grey,
                                          );
                                          break;
                                      }
                                    },
                                  ),
                                  iconSize: 32.0,
                                  onPressed: () => { controller.toggleTorch() },
                                ),
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: appGreen400,
                              radius: 30,
                              child: IconButton(
                                color: Colors.white,
                                icon: const Icon(Icons.image),
                                iconSize: 32.0,
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  // Pick an image
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 25
                                  );
                                  if (image != null) {
                                    var barcode = await controller.analyzeImage(image.path);
                                    if (barcode != null) {
                                      if (!mounted) return;
                                      // ScaffoldMessenger.of(context).showSnackBar(
                                      //   const SnackBar(
                                      //     content: Text('Barcode found!'),
                                      //     backgroundColor: Colors.green,
                                      //   ),
                                      // );
                                      onDetect(barcode);
                                    } else {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('No QR code detected!'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ),);
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BarcodeOverlay extends CustomPainter {
  BarcodeOverlay({
    required this.barcodeCorners,
    required this.barcodeSize,
    required this.boxFit,
    required this.cameraPreviewSize,
  });

  final List<Offset> barcodeCorners;
  final Size barcodeSize;
  final BoxFit boxFit;
  final Size cameraPreviewSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (barcodeCorners.isEmpty ||
        barcodeSize.isEmpty ||
        cameraPreviewSize.isEmpty) {
      return;
    }

    final adjustedSize = applyBoxFit(boxFit, cameraPreviewSize, size);

    double verticalPadding = size.height - adjustedSize.destination.height;
    double horizontalPadding = size.width - adjustedSize.destination.width;
    if (verticalPadding > 0) {
      verticalPadding = verticalPadding / 2;
    } else {
      verticalPadding = 0;
    }

    if (horizontalPadding > 0) {
      horizontalPadding = horizontalPadding / 2;
    } else {
      horizontalPadding = 0;
    }

    final double ratioWidth;
    final double ratioHeight;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      ratioWidth = barcodeSize.width / adjustedSize.destination.width;
      ratioHeight = barcodeSize.height / adjustedSize.destination.height;
    } else {
      ratioWidth = cameraPreviewSize.width / adjustedSize.destination.width;
      ratioHeight = cameraPreviewSize.height / adjustedSize.destination.height;
    }

    final List<Offset> adjustedOffset = [
      for (final offset in barcodeCorners)
        Offset(
          offset.dx / ratioWidth + horizontalPadding,
          offset.dy / ratioHeight + verticalPadding,
        ),
    ];

    final cutoutPath = Path()..addPolygon(adjustedOffset, true);

    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawPath(cutoutPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
