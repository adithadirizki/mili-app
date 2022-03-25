import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/favorite.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({
    Key? key,
  }) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<FavoriteResponse> items = [];
  bool isLoading = true;

  final _favoriteNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initDB();
    });
  }

  FutureOr<void> _handleError(Object e) {
    snackBarDialog(context, e.toString());
  }

  Future<void> initDB() async {
    setState(() {
      isLoading = true;
    });

    await Api.getFavorite().then((response) {
      var status = response.statusCode;
      if (status == 200) {
        Map<String, dynamic> bodyMap =
            json.decode(response.body) as Map<String, dynamic>;
        var pagingResponse = PagingResponse.fromJson(bodyMap);
        items = pagingResponse.data
            .map((dynamic e) =>
                FavoriteResponse.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      }
    }).catchError(_handleError);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onRefresh() {
    return initDB();
  }

  Future<void> saveFavorite(FavoriteResponse fav) async {
    await Api.updateFavorite(
      fav.serverId,
      _favoriteNameController.text,
    ).then((response) {
      if (response.statusCode == 200) {
        snackBarDialog(context, 'Berhasil menyimpan nomor');
        initDB();
      }
    }).catchError(_handleError);
    _favoriteNameController.clear();
  }

  void renameFavorite(FavoriteResponse fav) async {
    _favoriteNameController.text = fav.name ?? '';
    await Future<void>.delayed(const Duration(milliseconds: 500));
    showDialog<Widget>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          // title: const Text('Nama'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 20.0),
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _favoriteNameController,
                    autofocus: true,
                    decoration: generateInputDecoration(
                      label: 'Nama',
                      hint: '',
                      // errorMsg: !_valid ? AppLabel.errorRequired : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _favoriteNameController.clear();
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: Theme.of(context).textTheme.button,
              ),
            ),
            TextButton(
              onPressed: () async {
                saveFavorite(fav);
                await Navigator.of(context).maybePop();
              },
              child: Text(
                'Simpan',
                style: Theme.of(context).textTheme.button,
              ),
            )
          ],
        );
      },
    );
  }

  void removeFavorite(FavoriteResponse fav) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    confirmDialog(
      context,
      title: 'Konfirmasi',
      msg: 'Hapus nomor ?',
      confirmAction: () {
        Api.removeFavorite(fav.serverId).then((response) {
          if (response.statusCode == 200) {
            initDB();
          }
        }).catchError(_handleError);
      },
      cancelAction: () {
        // popScreen(context);
      },
      confirmText: 'Ya',
      cancelText: 'Tidak',
    );
  }

  void purchase(FavoriteResponse fav) {
    openPurchaseScreen(context,
        productCode: fav.productCode,
        groupName: fav.groupName ?? '',
        destination: fav.destination);
  }

  Widget buildFavoriteItem(FavoriteResponse item) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? '-Set Nama-',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    PopupMenuButton(
                      child: const Icon(
                        Icons.more_vert_outlined,
                        color: Colors.grey,
                        size: 22,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text("Ganti nama",
                              style: Theme.of(context)
                                  .textTheme
                                  .button!
                                  .copyWith()),
                          value: 1,
                          onTap: () {
                            renameFavorite(item);
                          },
                        ),
                        PopupMenuItem(
                          child: Text("Hapus",
                              style: Theme.of(context)
                                  .textTheme
                                  .button!
                                  .copyWith()),
                          value: 2,
                          onTap: () {
                            removeFavorite(item);
                          },
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          item.productName ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    Text(
                      item.destination,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                AppButton(
                  item.productCode.startsWith('PAY') ? 'Bayar' : 'Beli',
                  () {
                    purchase(item);
                  },
                  size: const Size(80, 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItems(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isNotEmpty
          ? ListView(
              children: [
                for (var history in items) buildFavoriteItem(history),
              ],
            )
          : const Center(
              child: Image(
                image: AppImages.emptyPlaceholder,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar2(
        title: 'Nomor Favorit',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: buildItems(context),
      ),
    );
  }

  @override
  void dispose() {
    // stopTimer();
    super.dispose();
  }
}
