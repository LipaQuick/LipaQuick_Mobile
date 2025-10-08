import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/local_db/database/database.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/contacts/contacts_model.dart';
import 'package:lipa_quick/core/models/contacts/contacts_response_model.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/provider/DBProvider.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/view_models/base_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/main.dart';
import 'package:workmanager/workmanager.dart';

class ContactsDBViewModel extends BaseModel {
  AppDatabase? contactsDatabase;
  static final ContactsDBViewModel _instance = ContactsDBViewModel._internal();
  final Api _api = locator<Api>();
  List<ContactsAPI>? currentContacts;

  factory ContactsDBViewModel() {
    return _instance;
  }

  ContactsDBViewModel._internal() {
    initializeDb();
  }

  void initializeDb() async {
    // initialization logic
    if (kDebugMode) {
      print('Building Application DB');
    }
    contactsDatabase = await DBProvider.db.database;
    //locator.signalReady(this);
    //contactsDatabase = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }

  Future<dynamic> getContact() async {
    if (contactsDatabase != null)
      contactsDatabase?.contactsDao.getAllContacts();
  }

  // > < | & * ( ) { }
  Future<dynamic> getContacts(bool refreshContacts) async {
    setState(ViewState.Loading);

    String userDetails = await LocalSharedPref().getUserDetails();
    UserDetails userDetail = UserDetails.fromJson(jsonDecode(userDetails));

    //check internet here
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      //print('Connectivity Result');
      // I am connected to a mobile network.
      setState(ViewState.Error);
      return const APIException(
          "No internet connection, please check your internet connection.",
          0,
          APIError.INTERNET_NOT_AVAILABLE);
    }
    List<Contacts> systemContact;
    List<ContactsAPI> data =
        await contactsDatabase!.contactsDao.getAllContacts();
    List<Contact> datas;
    var response;

    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    if (refreshContacts) {
      print('Inside refreshContacts ${refreshContacts}');
      List<Contact> systemContacts = await ContactsService.getContacts();

      List<Contact> filteredContacts = List.empty(growable: true);
      for (int i = 0; i < systemContacts.length; i++) {
        if (systemContacts[i].displayName!= null
            && systemContacts[i].displayName!.trim().isNotEmpty &&
            systemContacts[i].phones!.isNotEmpty
            && systemContacts[i].phones![0].value!.trim().isNotEmpty
            && !systemContacts[i].phones![0].value!.trim().contains(',')
            && systemContacts[i].phones![0].value!.length < 16
            && !systemContacts[i].phones![0].value!.trim().contains(userDetail.phoneNumber)
        ) {
          Contact contact = systemContacts[i];
          contact.phones![0].value = getReplacedvalue(contact);
          //print('Contact: ${getReplacedvalue(contact)}');
          filteredContacts.add(contact);
        } else {
          print('Item Name and Number is Empty: $i');
        }
      }

      List<ContactsAPI> refreshedSysContacts = filteredContacts
          .map((e) => ContactsAPI.name(
              '',
              e.displayName,
          getReplacedvalue(e).length>10?
              getReplacedvalue(e)
                  .substring(1, getReplacedvalue(e).length):getReplacedvalue(e),
              '',
              '',
              '',
              '',
              ''))
          .toList(growable: true);

      print('getContacts systemContacts ${systemContacts.length}');

      refreshedSysContacts = getRemovedContacts(refreshedSysContacts, data);

      List<Contacts> removedContacts = refreshedSysContacts
          .map((e) => Contacts('', e.name, e.phoneNumber))
          .toList(growable: true);

      response = await _api.syncContacts(removedContacts);

      if (response is APIException) {
        setState(ViewState.Idle);
        return response;
      }

      if (response is ContactsResponse) {
        if (response.status!) {
          await insertContacts(response.data!);
        }
      }

      data = await contactsDatabase!.contactsDao.getAllContacts();
      currentContacts ??= [];
      currentContacts?.addAll(data);
      setState(ViewState.Idle);

      registerTask();

      return currentContacts;
    }
    else {
      print('Outsize refreshContacts $refreshContacts');
      print('Data Empty? ${data.isEmpty}');
      if (data.isEmpty) {
        print('Data is Empty, Getting Contacts');
        datas = await ContactsService.getContacts();
        print(
            'Data is Empty, Contacts : ${datas.length} Start Time: ${DateTime.now()}');
        try {
          List<Contact> filteredContacts = List.empty(growable: true);
          for (int i = 0; i < datas.length - 1; i++) {
            if (datas[i].displayName != null && datas[i].phones != null) {
              if (datas[i].phones!.length > 0 &&
                  datas[i].phones![0].value != null) {
                if (datas[i].displayName!.trim().isNotEmpty &&
                    datas[i].phones![0].value!.trim().isNotEmpty &&
                    datas[i].phones![0].value!.trim().length < 16
                    && !datas[i].phones![0].value!.trim().contains(userDetail.phoneNumber)
                ) {
                  filteredContacts.add(datas[i]);
                }
              }
            } else {
              print('Item Name and Number is Empty: ${i}');
            }
          }

          systemContact = filteredContacts.map((e) {
            if (e.phones!.isNotEmpty) {
              return Contacts(
                  '',
                  e.displayName,
                  getReplacedvalue(e).length>10?
              getReplacedvalue(e)
                  .substring(1, getReplacedvalue(e).length):getReplacedvalue(e));
            } else {
              return Contacts('', e.displayName, '');
            }
          }).toList(growable: true);
          print(
              'Data is Empty, System Contacts : ${systemContact.length} END Time: ${DateTime.now()}');
          response = await _api.syncContacts(systemContact);
        } catch (e) {
          //print(e.toString());
        }

        //print('Checking Response ${response.toString()}');
        if (response is APIException) {
          print('Response is APIException');
          setState(ViewState.Idle);
          return response;
        }

        if (response is ContactsResponse) {
          print('Response is ContactsResponse');
          if (response.status!) {
            await insertContacts(response.data!);
          }
        }
      }

      registerTask();

      data = await contactsDatabase!.contactsDao.getAllContacts();
      currentContacts ??= [];
      currentContacts?.addAll(data);
      setState(ViewState.Idle);
      return currentContacts;
    }
  }

  Future<dynamic> getRefreshContacts() async {
    setState(ViewState.Loading);

    //check internet here
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // I am connected to a mobile network.
      return const APIException(
          "No internet connection, please check your internet connection.",
          0,
          APIError.INTERNET_NOT_AVAILABLE);
    }
    List<ContactsAPI> systemContact;
    List<ContactsAPI> data =
        await contactsDatabase!.contactsDao.getAllContacts();
    List<Contact> datas;
    var response;
    ContactsResponse contactsResponse;

    data = await contactsDatabase!.contactsDao.getAllContacts();

    if (currentContacts == null) {
      currentContacts = [];
    }
    currentContacts?.addAll(data);
    setState(ViewState.Idle);
    return currentContacts;
  }

  //Contacts
  Future<void> insertContacts(List<ContactsAPI> contacts) async {
    contactsDatabase!.contactsDao.insertContacts(contacts);
  }

  //Contacts
  Future<Future<List<ContactsAPI>>> getAllContacts() async {
    return contactsDatabase!.contactsDao.getAllContacts();
  }

  Future<List<ContactsAPI>> getContactsByQuery(String query) async {
    return contactsDatabase!.contactsDao.getAllContacts();
  }

  List<ContactsAPI> getRemovedContacts(
      List<ContactsAPI> systemContact, List<ContactsAPI> contacts) {
    // for (var element in systemContact) {
    //   print('System Contact: ${element.toJson().toString()}');
    // }
    // for (var element in contacts) {
    //   print('DB Contact: ${element.toJson().toString()}');
    // }

    systemContact.removeWhere((element) {
      //print('${element.toJson().toString()}, Checking if the contains this item
      // ${systemContact.contains(element)}');
      return contacts.contains(element);
    });

    return systemContact;
  }

  Future<List<ContactsAPI>>? filterContacts(String query) async {
    setState(ViewState.Loading);
    final Completer<List<ContactsAPI>> completer =
        Completer<List<ContactsAPI>>();
    if (currentContacts == null) {
      completer.complete(List.empty());
      return completer.future;
    }
    query = '%$query%';
    List<ContactsAPI> filteredContacts =
        await contactsDatabase!.contactsDao.getContactsByQuery(query);

    print('Filtered Contact Size: ${filteredContacts.length}');
    completer.complete(filteredContacts);
    setState(ViewState.Idle);
    return completer.future;
  }

  syncContacts() async {
    print('Started Background Sync via WorkManager');
    dynamic listContacts = _api.getContacts();

    if (listContacts is ContactsResponse) {
      print('GOT Contacts from API');
      if (listContacts.status!) {
        print('Its status from API');
        await insertContacts(listContacts.data!);
      }
    }
  }

  Future<void> deleteContacts() async {
    return contactsDatabase!.contactsDao.deleteContacts();
  }

  void registerTask() {
    if (Platform.isIOS) {
      Workmanager().registerPeriodicTask(
          backgroundContactSync, backgroundContactSync,
          initialDelay: Duration(seconds: 10),
          inputData: <String, dynamic>{
            'key': Random().nextInt(64000),
          });
    } else {
      Workmanager().registerOneOffTask(
          backgroundContactSync, backgroundContactSync,
          inputData: <String, dynamic>{
            'key': Random().nextInt(64000),
          });
    }
  }

  getReplacedvalue(Contact e) {
    print(e.phones![0].value);
    return e.phones![0].value!
        .replaceAll(' ', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', '');
  }
}
