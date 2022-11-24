import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:medicine/base_helper.dart';
import 'package:medicine/view_model/list_model.dart';
import 'package:medicine/medicine.dart';
import 'package:medicine/photo.dart';
import 'package:medicine/view/add_page.dart';
import 'package:medicine/view/edit_page.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum SortItem {
  newItem,
  oldItem,
}

class ListPage extends StatelessWidget {
  String searchText = "";
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ListModel>(
        create: (_) => ListModel()..getList(),
        child: Consumer<ListModel>(builder: (context, model, child) {
          BannerAd myBanner = BannerAd(
              adUnitId: model.getTestAdBannerUnitId(),
              size: AdSize.banner,
              request: const AdRequest(),
              listener: BannerAdListener(
                onAdLoaded: (Ad ad) => debugPrint('Ad loaded.'),
                onAdFailedToLoad: (Ad ad, LoadAdError error) {
                  debugPrint('Ad failed to load: $error');
                },
                onAdOpened: (Ad ad) => debugPrint('Ad opened.'),
                onAdClosed: (Ad ad) => debugPrint('Ad closed.'),
              ));
          myBanner.load();
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text('お薬手帳リスト'),
                  backgroundColor: Colors.pink[100],
                  actions: [
                    PopupMenuButton<SortItem>(
                        icon: const Icon(Icons.sort),
                        onSelected: (value) {
                          if (value == SortItem.oldItem) {
                            model.sortList(value);
                          } else if (value == SortItem.newItem) {
                            model.sortList(value);
                          }
                        },
                        itemBuilder: (context) => const [
                              PopupMenuItem(
                                  value: SortItem.oldItem, child: Text('古い順')),
                              PopupMenuItem(
                                  value: SortItem.newItem, child: Text('新しい順'))
                            ]),
                  ],
                ),
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (_seartchText) {
                          searchText = _seartchText;
                          model.search(searchText);
                        },
                        decoration: const InputDecoration(
                          hintText: "病院名または診察科目を検索",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0))),
                        ),
                      ),
                    ),
                    Consumer<ListModel>(builder: (context, model, child) {
                      if (searchText == "") {
                        return Expanded(
                          child: ListView(
                              children: model.medicineList
                                  .map(
                                    (medicine) => Card(
                                        elevation: 20.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Slidable(
                                          endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            children: [
                                              //削除ボタン
                                              SlidableAction(
                                                  flex: 1,
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.delete,
                                                  label: '削除',
                                                  onPressed: (BuildContext
                                                      context) async {
                                                    await deleteDialog(model,
                                                        context, medicine);
                                                  }),
                                              //編集ボタン
                                              SlidableAction(
                                                flex: 1,
                                                backgroundColor: Colors.brown,
                                                foregroundColor: Colors.white,
                                                icon: Icons.edit,
                                                label: '編集',
                                                onPressed: (BuildContext
                                                    context) async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => EditPage(
                                                          medicine
                                                              .hospitalText!,
                                                          medicine
                                                              .examinationText!,
                                                          medicine.image!
                                                              .split(','),
                                                          medicine.id!),
                                                      fullscreenDialog: true,
                                                    ),
                                                  );
                                                  model.isLoading();
                                                  await model.getList();
                                                  model.isReloading();
                                                },
                                              )
                                            ],
                                          ),
                                          //リスト
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            tileColor: Colors.pink[100],
                                            //リストに画像を表示する。
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '病院名:${medicine.hospitalText}\n診察科目:${medicine.examinationText}\n日付:${medicine.time}'),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10, bottom: 10),
                                                  child: imageView(
                                                      model, medicine, context),
                                                )
                                              ],
                                            ),
                                            textColor: Colors.white,
                                            //アイコン
                                            trailing: const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 50),
                                                child: Icon(
                                                  Icons.arrow_left,
                                                  color: Colors.white,
                                                  size: 40,
                                                )),
                                          ),
                                        )),
                                  )
                                  .toList()),
                        );
                      } else {
                        return Expanded(
                          child: ListView(
                              children: model.searchList
                                  .map(
                                    (medicine) => Card(
                                        elevation: 20.0,
                                        child: Slidable(
                                          endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            children: [
                                              //削除ボタン
                                              SlidableAction(
                                                  flex: 1,
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.delete,
                                                  label: '削除',
                                                  onPressed: (BuildContext
                                                      context) async {
                                                    await deleteDialog(model,
                                                        context, medicine);
                                                  }),
                                              //編集ボタン
                                              SlidableAction(
                                                flex: 1,
                                                backgroundColor: Colors.brown,
                                                foregroundColor: Colors.white,
                                                icon: Icons.edit,
                                                label: '編集',
                                                onPressed: (BuildContext
                                                    context) async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => EditPage(
                                                          medicine
                                                              .hospitalText!,
                                                          medicine
                                                              .examinationText!,
                                                          medicine.image!
                                                              .split(','),
                                                          medicine.id!),
                                                      fullscreenDialog: true,
                                                    ),
                                                  );
                                                  model.isLoading();
                                                  await model.getList();
                                                  model.isReloading();
                                                },
                                              )
                                            ],
                                          ),
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            tileColor: Colors.pink[100],
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '病院名:${medicine.hospitalText}\n診察科目:${medicine.examinationText}\n日付:${medicine.time}'),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10, bottom: 10),
                                                  child: imageView(
                                                      model, medicine, context),
                                                )
                                              ],
                                            ),
                                            textColor: Colors.white,
                                            trailing: const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 50),
                                                child: Icon(
                                                  Icons.arrow_left,
                                                  color: Colors.white,
                                                  size: 40,
                                                )),
                                          ),
                                        )),
                                  )
                                  .toList()),
                        );
                      }
                    }),
                    adBanner(myBanner)
                  ],
                ),
                floatingActionButton: Consumer<ListModel>(
                  builder: (context, model, child) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 70, left: 50),
                      child: FloatingActionButton(
                        backgroundColor: Colors.pink[100],
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPage(),
                              fullscreenDialog: true,
                            ),
                          ).then((_) async {
                            //画面が戻ったら処理が発動する
                            model.isLoading();
                            await model.getList();
                            model.isReloading();
                          });
                        },
                        tooltip: '追加する',
                        child: const Icon(Icons.add),
                      ),
                    );
                  },
                ),
              ),
              if (model.loading) showIndicator(context)
            ],
          );
        }));
  }

  Widget imageView(ListModel model, Medicine medicine, BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: model
            .imageList(medicine.image!.split(','))
            .map(
              (image) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Photo(
                            medicineImage: image,
                          ),
                          fullscreenDialog: true,
                        ),
                      );
                      model.isLoading();
                      await model.getList();
                      model.isReloading();
                    },
                    //写真
                    child: medicine.image != null
                        ? SizedBox(
                            width: 60,
                            height: 65,
                            child: Base64Helper().imageFromBase64String(image))
                        : Container(width: 45, height: 50, color: Colors.grey)),
              ),
            )
            .toList(),
      ),
    );
  }

  //インジゲータ
  Widget showIndicator(BuildContext context) {
    return const ColoredBox(
      color: Colors.black54,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  //広告バナー
  Widget adBanner(BannerAd myBanner) {
    return Container(
      color: Colors.white,
      height: 64.0,
      width: double.infinity,
      child: AdWidget(ad: myBanner),
    );
  }

  //削除ダイアログ
  Future deleteDialog(
      ListModel model, BuildContext context, Medicine medicine) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('削除しますか?'),
          actions: <Widget>[
            TextButton(
              child: const Text("はい"),
              onPressed: () async {
                await model.delete(medicine.id!);
                await model.getList();
                Navigator.pop(context);
              },
            ),
            TextButton(
                child: const Text('いいえ'),
                onPressed: () async {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
}
