import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:medicine/Common/base_helper.dart';
import 'package:medicine/view_model/edit_model.dart';
import 'package:provider/provider.dart';

class EditPage extends StatelessWidget {
  EditPage(this.hospitalText, this.examinationText, this.imageList, this.id);
  final String hospitalText;
  final String examinationText;
  final List<String> imageList;
  final int id;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditModel>(
      create: (_) => EditModel(hospitalText, examinationText, imageList, id),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 224, 234),
        appBar: AppBar(
          title: const Text('編集'),
          backgroundColor: Colors.pink[100],
        ),
        body: Consumer<EditModel>(builder: (context, model, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: <Widget>[
                  //枠線
                  upperFrameLine(top: 8, bottom: 8, text: "写真"),
                  //写真一覧
                  imageCarouselSliderView(model),
                  //インジケータ
                  imageIndicatorView(model),
                  //カメラボタン
                  cameraButton(model),
                  //枠線
                  underFrameLine(top: 10, bottom: 10),
                  //病院名/診察科目の枠線
                  upperFrameLine(top: 8, bottom: 8, text: "病院名/診察科目"),
                  //病院名/診察科目欄
                  hospitalWithExaminationField(model),
                  //枠線
                  underFrameLine(top: 20, bottom: 20),
                  //編集ボタン
                  updateButton(model, context)
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget upperFrameLine({double? top, double? bottom, String? text}) {
    return Padding(
      padding: EdgeInsets.only(top: top!, bottom: bottom!),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 10,
          ),
          Text(
            text!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            height: 3,
            width: text == "病院名/診察科目" ? 230 : 310,
            color: const Color.fromARGB(255, 190, 184, 184),
          ),
        ],
      ),
    );
  }

  Widget underFrameLine({double? top, double? bottom}) {
    return Padding(
      padding: EdgeInsets.only(top: top!, bottom: bottom!),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 10,
          ),
          Container(
            height: 3,
            width: 350,
            color: const Color.fromARGB(255, 190, 184, 184),
          ),
        ],
      ),
    );
  }

  //写真
  Widget imageCarouselSliderView(EditModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CarouselSlider(
              options: CarouselOptions(
                  height: 200,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, _) {
                    model.onPageIndex(index);
                  }),
              items: model
                  .imageList(model.base64ImageStringList!)
                  .map(
                    (image) => Builder(builder: (BuildContext context) {
                      return Container(
                          color: Colors.white,
                          margin: const EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: InkWell(
                              onTap: () async {
                                //　カメラを起動
                                await model.getImageCamera(model
                                    .base64ImageStringList!
                                    .indexOf(image));
                              },
                              //写真
                              child: Container(
                                  child: Base64Helper()
                                      .imageFromBase64String(image))));
                    }),
                  )
                  .toList()),
        )
      ],
    );
  }

  //画像の枚数を示すインジケーター
  Widget imageIndicatorView(EditModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: model.base64ImageStringList!.map((index) {
        int imageIndex = model.base64ImageStringList!.indexOf(index);
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: model.current == imageIndex
                ? const Color.fromARGB(255, 253, 184, 242)
                : const Color.fromARGB(255, 255, 252, 252),
          ),
        );
      }).toList(),
    );
  }

  //カメラボタン
  Widget cameraButton(EditModel model) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
            height: 50,
            width: 300,
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.pink[100]),
              onPressed: () async {
                await model.getImageCamera(null);
              },
              child: const Icon(Icons.camera_alt),
            )));
  }

  //病院名/診察科目入力欄
  Widget hospitalWithExaminationField(EditModel model) {
    return Container(
      width: 350,
      height: 230,
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 246, 209, 222)),
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: Column(children: <Widget>[
        const SizedBox(
          height: 20,
        ),
        //病院名欄
        SizedBox(
          width: 300,
          child: TextField(
            controller: model.textController,
            style: const TextStyle(
              fontSize: 15,
            ),
            decoration: const InputDecoration(
              labelText: '病院名',
              hintText: '〇〇病院',
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 246, 209, 222),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            onChanged: (text) {
              model.hospitalText = text;
            },
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        //診察科目欄
        SizedBox(
          width: 300,
          child: TextField(
            controller: model.textController2,
            style: const TextStyle(
              fontSize: 15,
            ),
            decoration: const InputDecoration(
                labelText: '診療科目',
                hintText: '皮膚科',
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 246, 209, 222),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
            onChanged: (text2) {
              model.examinationText = text2;
            },
          ),
        ),
      ]),
    );
  }

  Widget updateButton(EditModel model, BuildContext context) {
    return SizedBox(
      height: 50,
      width: 200,
      child: ElevatedButton(
          child: const Text('編集'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[100],
          ),
          onPressed: () async {
            await updeteDialog(model, context);
          }),
    );
  }

  //更新ダイアログ
  Future updeteDialog(EditModel model, BuildContext context) async {
    try {
      await model.update();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('更新しました。'),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          );
        },
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('更新できませんでした'),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
}
