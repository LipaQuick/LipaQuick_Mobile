import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/global/Application.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/services/blocs/chat_bloc.dart';
import 'package:lipa_quick/core/services/events/chat_events.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/views/chat/chat_page/user_chat_page.dart';
import 'package:lipa_quick/ui/views/chat/widgets/download_helpers.dart';
import 'package:lipa_quick/ui/views/chat/widgets/player_video.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatWigets {
  Widget createMessageItemView(
      SignalRBloc vm, RecentChats message, BuildContext context, int position) {
    var borderRadius = !message.self!
        ? const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10))
        : const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10));
    if (vm.checkIsImage(message.chatDoc)) {
      return ImageView(message, context, borderRadius);
    } else if (vm.checkIsVideo(message.chatDoc!)) {
      return VideoMessageView(message, context, borderRadius);
    } else if (vm.checkIsDocument(message.chatDoc)) {
      return DocumentView(vm, message, context, borderRadius, position);
    } else if (message.message != null && !message.message!.isNotEmpty) {
      return TextMessageView(message, context, borderRadius);
    } else if(message.isLoadMore != null && message.isLoadMore!){
      return Container(
        width: MediaQuery.of(context).size.width / 2,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: (message.self! ? appGreen400 : Colors.white),
        ),
        child: Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      );
    }else{
      return TextMessageView(message, context, borderRadius);
    }
  }

  Widget TextMessageView(
      RecentChats message, BuildContext context, BorderRadius borderRadius) {
    return Column(
      children: [
        Container(
          child: Align(
            alignment: (message.self! ? Alignment.topRight : Alignment.topLeft),
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: (message.self! ? appGreen400 : Colors.white),
              ),
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message ?? 'Empty Messsage',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: message.self! ? Colors.white : Colors.black),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(getTime(message.modifiedAt!)),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  Widget ImageView(
      RecentChats message, BuildContext context, BorderRadius borderRadius) {
    return Column(
      children: [
        Container(
          child: Align(
            alignment: (message.self! ? Alignment.topRight : Alignment.topLeft),
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: (message.self! ? appGreen400 : Colors.white),
              ),
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    getFilePathUrl(message.chatDoc!),
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.width / 2,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      //debugPrint(stackTrace);
                      return Image.asset(Assets.icon.invalidImage.path,
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: MediaQuery.of(context).size.width / 2);
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(getTime(message.modifiedAt!)),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  String getTime(String dateTimeM) {
    DateTime dateTime =
        DateTime.parse(dateTimeM.substring(0, dateTimeM.length - 3));
    DateFormat format = DateFormat('hh:mm');
    var result =
        '${format.format(dateTime).toString()}${(dateTimeM.substring(dateTimeM.length - 3, dateTimeM.length))}';
    //debugPrint(result);
    return result;
  }

  String getFilePathUrl(String chatDoc) {
    debugPrint('${ApplicationData().BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}');
    return '${ApplicationData().BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}';
  }

  String getFileName(String chatDoc) {
    debugPrint('${ApplicationData().BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}'.split('/').last);
    return '${ApplicationData().BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}'.split('/').last;
  }

  Widget DocumentView(
      SignalRBloc vm, RecentChats message, BuildContext context, BorderRadius borderRadius, int position) {
    var size = MediaQuery.of(context).size.width / 6;
    var iconSize = size - 5;
    var textBackSize = iconSize - 10;
    var textHeight = size / 5;
    var vm = context.read<SignalRBloc>();
    DownloadStatus status = DownloadStatus.notDownloaded;
    vm.checkIfFileDownloaded(message.chatDoc!).then((value) => {
          status = value,
        });

    var downloadController = WidgetDownloadController(
        downloadStatus: status!,
        onOpenDownload: () {
          _onOpenDowload(getFileName(message.chatDoc!));
        },
        progress: 0.0,
        downloadFile: getFilePathUrl(message.chatDoc!),
     downloadFileName: getFileName(message.chatDoc!));

    return Column(
      children: [
        Align(
          alignment: (message.self! ? Alignment.topRight : Alignment.topLeft),
          child: Container(
            width: (MediaQuery.of(context).size.width / 3) * 2.2,
            height: MediaQuery.of(context).size.width / 5.5,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: (message.self! ? appGreen400 : Colors.white),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    children: <Widget>[
                      Container(
                          width: size,
                          height: size,
                          child: Icon(
                            Icons.insert_drive_file,
                            color: message.self! ? Colors.white : appGreen400,
                            size: 60.0,
                            semanticLabel: 'File not downloaded, Download File',
                          )),
                      Container(
                          width: size,
                          margin: EdgeInsets.only(bottom: 18),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: textBackSize,
                            height: textHeight,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0))),
                            child: Text(
                              FileUtils().getFileExtension(message.chatDoc!),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    FileUtils().getFile(message.chatDoc!),
                                    style: TextStyle(
                                      color: message.self!
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.57,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    getTime(message.modifiedAt!),
                                    style: TextStyle(
                                      color: message.self!
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.33,
                                      letterSpacing: -0.06,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: AnimatedBuilder(
                          animation: downloadController,
                          builder: (context, child) {
                            return DownloadButton(
                              status: downloadController.downloadStatus,
                              downloadProgress: downloadController.progress,
                              onDownload: downloadController.startDownload,
                              onCancel: downloadController.stopDownload,
                              onOpen: downloadController.openDownload,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 30,
                        height: 30,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 1.33),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: InkWell(
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 30.0,
                            semanticLabel: 'Delete document from chat list',
                          ),
                          onTap: (){
                            vm.add(SignalRMessageDelete(message.id, position));
                          },
                        ),
                      ),
                      const SizedBox(width: 8)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  Widget VideoMessageView(
      RecentChats message, BuildContext context, BorderRadius borderRadius) {
    var size = MediaQuery.of(context).size.width / 6;
    var iconSize = size - 5;
    var textBackSize = iconSize - 10;
    var textHeight = size / 5;
    var vm = context.read<SignalRBloc>();
    DownloadStatus status = DownloadStatus.notDownloaded;
    vm.checkIfFileDownloaded(message.chatDoc!).then((value) => {
      status = value,
    });

    var downloadController = WidgetDownloadController(
        downloadStatus: status!,
        onOpenDownload: () {
          _onOpenDowload(getFileName(message.chatDoc!));
        },
        progress: 0.0,
        downloadFile: getFilePathUrl(message.chatDoc!),
        downloadFileName: getFileName(message.chatDoc!));

    return Column(
      children: [
        Align(
          alignment: (message.self! ? Alignment.topRight : Alignment.topLeft),
          child: Container(
            width: (MediaQuery.of(context).size.width / 3) * 2.2,
            height: MediaQuery.of(context).size.width / 5.5,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: (message.self! ? appGreen400 : Colors.white),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    children: <Widget>[
                      Container(
                          width: size,
                          height: size,
                          child: Icon(
                            Icons.insert_drive_file,
                            color: message.self! ? Colors.white : appGreen400,
                            size: 60.0,
                            semanticLabel: 'File not downloaded, Download File',
                          )),
                      Container(
                          width: size,
                          margin: EdgeInsets.only(bottom: 18),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: textBackSize,
                            height: textHeight,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                BorderRadius.all(Radius.circular(4.0))),
                            child: Text(
                              FileUtils().getFileExtension(message.chatDoc!),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    FileUtils().getFile(message.chatDoc!),
                                    style: TextStyle(
                                      color: message.self!
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.57,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    getTime(message.modifiedAt!),
                                    style: TextStyle(
                                      color: message.self!
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.33,
                                      letterSpacing: -0.06,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: AnimatedBuilder(
                          animation: downloadController,
                          builder: (context, child) {
                            return DownloadButton(
                              status: downloadController.downloadStatus,
                              downloadProgress: downloadController.progress,
                              onDownload: downloadController.startDownload,
                              onCancel: downloadController.stopDownload,
                              onOpen: downloadController.openDownload,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 30,
                        height: 30,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 1.33),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 30.0,
                          semanticLabel: 'File not downloaded, Download File',
                        ),
                      ),
                      const SizedBox(width: 8)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  Future<void> _onOpenDowload(String filePath) async {
    var directory = await getApplicationDocumentsDirectory();
    directory = directory.absolute.parent;
    var path = '${directory.path}/files';
    var Filepath = '${path}/$filePath';
    debugPrint(path);
    OpenFile.open(Filepath);
  }
}

class MessageComposeView extends StatefulWidget {
  RecentChats? chats;

  MessageComposeView(this.chats);

  @override
  State<StatefulWidget> createState() => _MessageComposeViewState();
}

class _MessageComposeViewState extends State<MessageComposeView> {
  // Properties
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  // Methods

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _messageTextController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SignalRBloc>();
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTapUp: (TapUpDetails details) {
                showPopUpMenu(vm);
              },
              child: IconButton(
                  onPressed: null, icon: Icon(Icons.add, color: Colors.black)),
            ),
            Flexible(
              child: Card(
                color: Color(0xFFF7F7FC),
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: TextField(
                    controller: _messageTextController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: null,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: appGreen400, size: 30),
              onPressed: () {
                var message = _messageTextController.text;
                if (!message.isEmpty) {
                  _messageTextController.text = '';
                  FocusScope.of(context).requestFocus(FocusNode());
                  vm.add(SendMessagesEvent(widget.chats!, message));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Can't send empty message"),
                  ));
                }
              },
            )
          ],
        )
      ],
    );
  }

  void showPopUpMenu(SignalRBloc vm) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
                leading: Icon(Icons.money_outlined, color: Colors.green),
                title: Text('Send Money'),
                onTap: () {
                  Navigator.of(context).pop();
                  vm.add(SignalRFindUserDetailsEvent((widget.chats != null && widget.chats!.self!)
                      ?widget.chats!.receiverPhone
                      :widget.chats!.senderPhone));
                }),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: appGreen400,
              ),
              title: Text('Photos and Videos'),
              onTap: () {
                Navigator.of(context).pop();
                showImagePickerAndCrop(vm);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_camera,
                color: Colors.blue,
              ),
              title: Text('Camera'),
              onTap: (){
                showCameraCapture(vm);
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.contacts, color: Colors.blueGrey),
            //   title: Text('Contact'),
            //   onTap: (){
            //     showContactsPicker(vm);
            //   },
            // ),
            ListTile(
                leading: Icon(Icons.insert_drive_file, color: Colors.purple),
                title: Text('Document'),
                onTap: () {
                  Navigator.of(context).pop();
                  showDocumentPickerAndCrop(vm);
                }),
          ],
        );
      },
    );
  }

  Future<void> showImagePickerAndCrop([SignalRBloc? model]) async {
    final ImagePicker picker = ImagePicker();
    try{
      // Pick an image
      final XFile? image = await picker.pickMedia(
        requestFullMetadata: false
      );
      if (image != null) {
        _cropImage(image, model);
      }
    }on PlatformException catch(e){
      CustomDialog(DialogType.FAILURE).buildAndShowDialog(
          context: context,
          title: 'Chat',
          message: e.message,
          onPositivePressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          buttonPositive: 'OK');
    }catch(e) {

    }
  }

  Future<void> _cropImage(XFile _pickedFile, [SignalRBloc? model]) async {
    if (_pickedFile != null) {
      if(model!.checkIsImage(_pickedFile.path)){
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: _pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 60,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: appGreen400,
                statusBarColor: appGreen400,
                activeControlsWidgetColor: appGreen400,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                hideBottomControls: true,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Cropper',
            ),
          ],
        );
        if (croppedFile != null) {
          model!.add(SignalRUploadEvent(File(croppedFile.path)));
        }
      }else{
        //model!.add(SignalRUploadEvent(File(_pickedFile.path)));
        print(_pickedFile.path);
        showVideoBottomSheet(context, _pickedFile.path, model);
      }
    }
  }

  void showVideoBottomSheet(BuildContext context, String filePath, [SignalRBloc? model]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.black87,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.center,
                  child: RemoteVideoPlayer(filePath, (){
                    Navigator.of(context).pop();
                    model!.add(SignalRUploadEvent(File(filePath)));
                  }),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showDocumentPickerAndCrop([SignalRBloc? model]) async {
    String localPath = await model!.localPath;

    FilePickerResult? result =
    await FilePicker.platform.pickFiles(initialDirectory: localPath);

    if (result != null) {
      File file = File(result.files.single.path!);
      PlatformFile xfile = result.files.first;

      debugPrint(xfile.name);
      // debugPrint(xfile.bytes);
      // debugPrint(xfile.size);
      debugPrint(xfile.extension);
      print(xfile.path);
      model!.add(SignalRUploadEvent(file));
    }
  }

  Future<void> showCameraCapture([SignalRBloc? model]) async{
    //String localPath = await model!.localPath;

    final ImagePicker picker = ImagePicker();

    final XFile? photo = await picker.pickImage(source: ImageSource.camera,imageQuality: 25);

    if(photo != null){
      File file = File(photo.path);
      model!.add(SignalRUploadEvent(file));
    }
  }

  Future<void> showContactsPicker(SignalRBloc vm) async{
    final contact = await FlutterContacts.openExternalPick();
    if(contact != null){
      var contactVcard = contact.toVCard();

    }
  }
}
