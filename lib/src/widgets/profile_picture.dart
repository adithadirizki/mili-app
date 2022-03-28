import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/theme/images.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({Key? key}) : super(key: key);

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  FutureOr<void> handleError(BuildContext context, Object e) {
    snackBarDialog(context, e.toString());
  }

  void pickImage(BuildContext context, ImageSource source) async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxHeight: 1024,
      maxWidth: 1024,
      source: source,
    );

    if (result != null) {
      File? croppedFile = await ImageCropper.cropImage(
          sourcePath: result.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            // CropAspectRatioPreset.ratio3x2,
            // CropAspectRatioPreset.original,
            // CropAspectRatioPreset.ratio4x3,
            // CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.lightBlueAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null) {
        final bytes = await croppedFile.readAsBytes();
        Api.updatePhotoProfile(bytes, result.name).then((response) async {
          var status = response.statusCode;
          final respStr = await response.stream.bytesToString();
          var jsonData = json.decode(respStr) as Map<String, dynamic>;
          if (status == 200) {
            userBalanceState.fetchData();
          } else {
            handleError(
                context,
                jsonData['error_msg'] != null
                    ? (jsonData['error_msg'] as String)
                    : 'Proses gagal');
            debugPrint('Update profile err $jsonData');
          }
        }).catchError((dynamic e) {
          debugPrint('Update profile err ${e.toString()}');
        });
      }
    }
  }

  VoidCallback onPhotoTap(BuildContext context) {
    return () async {
      ImageSource? source = await bottomSheetDialog<ImageSource?>(
        context: context,
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
      );

      if (source == null) {
        return;
      }

      pickImage(context, source);
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: userBalanceState.isGuest() ? null : onPhotoTap(context),
      child: Container(
        decoration: BoxDecoration(
          // color: AppColors.blue5,
          border: Border.all(color: Colors.black38, width: 0.1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: UserBalanceScope.of(context).getPhotoUrl() == null
              ? const Image(
                  image: AppImages.photoProfilePlaceholder,
                  width: 80,
                  height: 80,
                )
              : FadeInImage(
                  image:
                      NetworkImage(UserBalanceScope.of(context).getPhotoUrl()!),
                  placeholder: AppImages.photoProfilePlaceholder,
                  width: 80,
                  height: 80,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return const Image(
                      image: AppImages.photoProfilePlaceholder,
                      width: 80,
                      height: 80,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
