// import 'package:file_picker/file_picker.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/customer_service.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
// import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';

class CustomerServiceScreen extends StatefulWidget {
  const CustomerServiceScreen({Key? key}) : super(key: key);

  @override
  _CustomerServiceScreenState createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends State<CustomerServiceScreen> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: '06c33e8b-e835-4736-80f4-63f44b66666c');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initDB();
    });
  }

  Future<void> initDB() async {
    await AppDB.syncCustomerService();

    Condition<CustomerService> filterUser =
        CustomerService_.userId.equals(userBalanceState.userId);

    final db = AppDB.customerServiceDB;
    QueryBuilder<CustomerService> query = db.query(filterUser)
      ..order(CustomerService_.messageDate, flags: 1);
    final items = query.build().find();

    debugPrint('Customer Service length ${items.length}');

    setState(() {
      _messages = items
          .map<types.Message>((e) => e.photoUrl == null || e.photo!.isEmpty
              ? types.TextMessage(
                  author: e.isOwnMessage ? _user : types.User(id: e.senderId),
                  createdAt: e.messageDate.millisecondsSinceEpoch,
                  id: e.id.toString(),
                  text: e.message,
                  status: types.Status.delivered,
                )
              : types.ImageMessage(
                  author: e.isOwnMessage ? _user : types.User(id: e.senderId),
                  createdAt: e.messageDate.millisecondsSinceEpoch,
                  id: e.id.toString(),
                  size: 100,
                  name: e.photoUrl!,
                  uri: e.photoUrl!,
                  status: types.Status.delivered,
                ))
          .toList(growable: true);
    });
  }

  void _addMessage(types.Message msg) {
    _messages.insert(0, msg);
    setState(() {});
  }

  void _handleAtachmentPressed() async {
    ImageSource? source = await bottomSheetDialog<ImageSource?>(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlinedButton(
              child: const Text('Ambil dari Kamera'),
              onPressed: () {
                Navigator.pop(context, ImageSource.camera);
              },
              style: outlineButtonStyle,
            ),
            const SizedBox(height: 5),
            OutlinedButton(
              child: const Text('Ambil dari Galeri'),
              onPressed: () {
                Navigator.pop(context, ImageSource.gallery);
              },
              style: outlineButtonStyle,
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );

    if (source == null) {
      return;
    }

    _handleImageSelection(source);
  }

  void _handleFileSelection() async {
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.any,
    // );
    //
    // if (result != null && result.files.single.path != null) {
    //   final message = types.FileMessage(
    //     author: _user,
    //     createdAt: DateTime.now().millisecondsSinceEpoch,
    //     id: const Uuid().v4(),
    //     mimeType: lookupMimeType(result.files.single.path!),
    //     name: result.files.single.name,
    //     size: result.files.single.size,
    //     uri: result.files.single.path!,
    //   );
    //
    //   _addMessage(message);
    // }
    final result = await ImagePicker().pickImage(
        imageQuality: 70,
        maxWidth: 1440,
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear);

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      debugPrint('Handle image selection ${result.path}');

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection(ImageSource source) async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1920,
      maxHeight: 1920,
      source: source,
    );

    if (result != null) {
      debugPrint('Handle image selection ${result.path}');
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path, // Uri from api
        width: image.width.toDouble(),
        status: types.Status.sending,
      );

      _addMessage(message);

      // Upload image
      debugPrint("Send Image >> ${result.name}");
      Api.sendImageMessage(bytes, result.name, userBalanceState.userId)
          .then((response) async {
        var status = response.statusCode;

        // final respStr = await response.stream.bytesToString();
        // var jsonData = json.decode(respStr) as Map<String, dynamic>;
        // debugPrint('Send message res ${status} ${jsonData.toString()}');

        if (status == 200) {
          final newMessage = message.copyWith(status: types.Status.delivered);
          _messages[0] = newMessage;
          setState(() {});
        }
      }).catchError((dynamic e) {
        final newMessage = message.copyWith(status: types.Status.error);
        _messages[0] = newMessage;
        setState(() {});
        debugPrint('Send message err ${e.toString()}');
      });
    }
  }

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      // await OpenFile.open(message.uri);
    }
  }

  void _handlePreviewDataFetched(
    types.Message message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  FutureOr<void> _handleError(Object e) {
    snackBarDialog(context, e.toString());
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
      status: types.Status.sending,
    );

    _addMessage(textMessage);

    Api.sendMessage(message.text, userBalanceState.userId).then((value) {
      debugPrint('Send message res ${value.body}');
      final newMessage = textMessage.copyWith(status: types.Status.delivered);
      _messages[0] = newMessage;
      setState(() {});
    }).catchError((dynamic e) {
      final newMessage = textMessage.copyWith(status: types.Status.error);
      _messages[0] = newMessage;
      setState(() {});
    });
  }

  Future<void> _handleEndReached() async {
    // final uri = Uri.parse(
    //   'https://api.instantwebtools.net/v1/passenger?page=$_page&size=20',
    // );
    // final response = await http.get(uri);
    // final json = jsonDecode(response.body) as Map<String, dynamic>;
    // final data = json['data'] as List<dynamic>;
    // final messages = data
    //     .map(
    //       (e) => types.TextMessage(
    //         author: _user,
    //         id: e['_id'] as String,
    //         text: e['name'] as String,
    //       ),
    //     )
    //     .toList();
    // setState(() {
    //   _messages = [..._messages, ...messages];
    //   _page = _page + 1;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: 'Customer Service'),
      body: SafeArea(
        bottom: false,
        child: Chat(
          l10n: const ChatL10nEn(
            inputPlaceholder: 'Pesan',
            emptyChatPlaceholder: 'Tidak ada pesan',
            sendButtonAccessibilityLabel: 'Kirim',
          ),
          messages: _messages,
          onAttachmentPressed: _handleAtachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          user: _user,
          usePreviewData: true,
          onEndReached: _handleEndReached,
          theme: DefaultChatTheme(
            backgroundColor: Theme.of(context).backgroundColor,
            inputBackgroundColor: Colors.grey,
            attachmentButtonIcon: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
            ),
            inputBorderRadius:
                const BorderRadius.all(Radius.elliptical(50, 50)),
            inputPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            inputTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: Colors.transparent,
              backgroundColor: Colors.transparent,
            ),
            errorIcon: const Icon(
              Icons.replay_outlined,
              color: Colors.redAccent,
              size: 14,
            ),
            deliveredIcon: const Icon(
              Icons.check_outlined,
              color: Colors.green,
              size: 14,
            ),
            sendingIcon: const Icon(
              Icons.watch_later_outlined,
              color: Colors.grey,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }
}
