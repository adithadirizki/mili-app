import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:miliv2/src/screens/purchase_pulsa.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';

class FlutterContactsExample extends StatefulWidget {
  @override
  _FlutterContactsExampleState createState() => _FlutterContactsExampleState();
}

class _FlutterContactsExampleState extends State<FlutterContactsExample> {
  TextEditingController queryController = TextEditingController();

  List<Contact>? _contacts;
  List<Contact>? contactFiltered;
  String? destination;
  String query = '';
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _fetchContacts();
    });
  }

  Future<void> _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() {
        _permissionDenied = true;
      });
    } else {
      List<Contact>? contacts = await FlutterContacts.getContacts();
      contacts = contacts.where((e) =>
        (e.displayName.contains(query))
      ).toList();

      setState(() {
        _contacts = contacts;
        contactFiltered = contacts;
      });
    }
  }

  Future<void> filterContact(String query) async {
    if (_permissionDenied) {
      setState(() {
        _permissionDenied = true;
      });
    } else {
      setState(() {
        contactFiltered = _contacts?.where((e) =>
          (e.displayName.toLowerCase().contains(query.toLowerCase()))
        ).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const SimpleAppBar2(title: 'Pilih Kontak'),
    backgroundColor: AppColors.white2,
    body: Column(
      children: [
        TextField(
          controller: queryController,
          decoration: generateInputDecoration(
            hint: 'Cari Kontak',
            label: null,
            onClear: query.isNotEmpty
                ? () {
              queryController.clear();
              query = '';
              filterContact(query);
              setState(() {});
            } : null,
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.grey,
            ),
            outlineBorder: true,
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            setState(() {
              query = value;
            });
            filterContact(value);
          },
        ),
        Expanded(child: _body())
      ],
    )
  );

  Future phoneList(Contact? contact) async {
    return await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var phone in contact!.phones) ListTile(
                title: Text(phone.number),
                onTap: () {
                  Navigator.pop(context, phone.number);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _body() {
    if (_permissionDenied) return const Center(child: Text('Permission denied'));
    if (contactFiltered == null) return const Center(child: CircularProgressIndicator());

    if (contactFiltered!.isEmpty) {
      return const Center(
        child: Text('-- kontak kosong --'),
      );
    }

    return ListView.builder(
        itemCount: contactFiltered!.length,
        itemBuilder: (context, i) => Card(
            child: ListTile(
              title: Text(contactFiltered![i].displayName, style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () async {
                final fullContact = await FlutterContacts.getContact(contactFiltered![i].id);
                dynamic phone = await phoneList(fullContact);
              if (phone != null) Navigator.pop(context, phone);
            })
        ),
    );
  }
}