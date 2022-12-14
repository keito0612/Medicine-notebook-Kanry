import 'package:flutter/material.dart';
import 'package:medicine/add_model.dart';
import 'package:medicine/base_helper.dart';
import 'package:provider/provider.dart';

class AddDate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '追加',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 248, 187, 208),
      ),
      home: AddPage(),
    );
  }
}

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddModel>.value(
      value: AddModel(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 224, 234),
        appBar: AppBar(
          title: const Text('追加'),
          backgroundColor: Colors.pink[100],
        ),
        body: Consumer<AddModel>(builder: (context, model, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: <Widget>[
                  //写真の枠線
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          '写真',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 3,
                          width: 310,
                          color: const Color.fromARGB(255, 190, 184, 184),
                        ),
                      ],
                    ),
                  ),
                  //写真
                  SizedBox(
                    width: 200,
                    height: 240,
                    child: InkWell(
                      onTap: () async {
                        //　カメラを起動
                        await model.getImagecamera();
                      },
                      child: model.imageFile != null
                          ? Base64Helper()
                              .imageFromBase64String(model.base64ImageString)
                          : Container(
                              child: const Icon(Icons.camera_alt),
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //枠線
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                  ),
                  //病院名/診察科目の枠線
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          '病院名/診察科目',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          height: 3,
                          width: 220,
                          color: const Color.fromARGB(255, 190, 184, 184),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 360,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 246, 209, 222)),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Column(children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 300,
                        child: TextField(
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (text) {
                            model.hospitalText = text;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: 300,
                        child: TextField(
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                          onChanged: (text2) {
                            model.examinationText = text2;
                          },
                        ),
                      ),
                    ]),
                  ),
                  //枠線
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
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
                  ),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                        child: const Text('追加'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.pink[100],
                        ),
                        onPressed: () async {
                          //お薬手帳を追加する
                          await addDialog(model, context);
                        }),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // 追加ダイアログ
  Future addDialog(AddModel model, BuildContext context) async {
    try {
      await model.add();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('追加しました。'),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      Navigator.of(context).pop();
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }
}
