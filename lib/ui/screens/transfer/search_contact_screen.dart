import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wave_ui_clone/ui/colors.dart';
import 'package:wave_ui_clone/ui/components/contactlist.dart';
import 'package:wave_ui_clone/ui/components/contacts_list.dart';
import 'package:wave_ui_clone/ui/components/leading_icon_listile.dart';
import 'package:wave_ui_clone/ui/screens/transfer/new_contact_screen.dart';
import 'package:wave_ui_clone/ui/screens/transfer/transfer_screen.dart';
import 'package:wave_ui_clone/utils/contact_utils.dart';

class SearchContact extends StatefulWidget {
  const SearchContact({Key? key}) : super(key: key);

  @override
  State<SearchContact> createState() => _SearchContactState();
}

class _SearchContactState extends State<SearchContact> {
  late TextEditingController _controller;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    //getAllContacts();
    _controller = TextEditingController();
    askContactsPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  askContactsPermission() async {
    final permission = await ContactUtils.getContactPermission();

    switch (permission) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.limited:
        goBackToHomePage();
        break;
      case PermissionStatus.granted:
        getAllContacts();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).errorColor,
            content: const Text("Veuillez donner l'App l'accés aux contacts!"),
            duration: const Duration(seconds: 3),
          ),
        );
        break;
    }
  }

  goBackToHomePage() => Navigator.of(context).pop();

  getAllContacts() async {
    List<Contact> _contacts = (await ContactsService.getContacts(
            withThumbnails: false, photoHighResolution: false))
        .toList();

    setState(() {
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Envoyer de l'argent",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          color: Colors.black,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 3,
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    cursorColor: skyBlue,
                    decoration: const InputDecoration(
                      labelText: 'À',
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      child: const ListTile(
                        leading: LeadingIcon(
                          containerColor: skyBlue,
                          icon: Icons.add,
                          iconColor: Colors.white,
                        ),
                        title: Text(
                          "Envoyer à un nouveau numéro",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewContact(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: const Text(
                        'Contacts',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //const ContactsList(),
                    ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          Contact contact = contacts[index];
                          var numbers = contact.phones?.toList();
                          return GestureDetector(
                            child: ListTile(
                              leading: const LeadingIcon(
                                containerColor: greyBackgroundIcon,
                                icon: Icons.person,
                                iconColor: greyIcon,
                              ),
                              title: Text('${contact.displayName}'),
                              subtitle: numbers!.length > 0
                                  ? Text('${numbers[0].value}')
                                  : null,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransferScreen(
                                      fullName: contact.displayName,
                                      phoneNumber:
                                          contact.phones?.elementAt(0).value),
                                ),
                              );
                            },
                          );
                        })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
