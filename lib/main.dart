import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';


final countProvider = StateProvider((ref) {
  return 0;
});



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日記投稿アプリ',
      theme: ThemeData.dark(),
      home: Authy(),
    );
  }
}


class Authy extends StatefulWidget {
  /* 認証機能 */
  @override
  _AuthyState createState() => _AuthyState();
}

class _AuthyState extends State<Authy> {
  String email = ''; // メールアドレス
  String password = ''; // パスワード

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('日記投稿アプリ'),
        centerTitle: true,
      ),

      body: Container(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget> [

              TextFormField(
                /* メールアドレスの入力フォーム */
                decoration: InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    email = value; // emailにアドレスを代入
                  });
                },
              ),

              TextFormField(
                /* パスワードの入力フォーム */
                decoration: InputDecoration(labelText: 'パスワード'),
                onChanged: (String value) {
                  setState(() {
                    password = value; // passwordにパスワードを代入
                  });
                },
              ),

              const SizedBox(height: 16.0),

              Container(
                /* ユーザー登録ボタン */
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('ユーザー登録'),
                  onPressed: () async {
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    await auth.createUserWithEmailAndPassword(
                      /* emailとpasswordでユーザー登録する */
                        email: email,
                        password: password,
                    );

                    await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return DiaryList();
                        }),
                    );

                  },
                ),
              ),

              const SizedBox(height: 8),

              Container(
                /* ログインボタン */
                width: double.infinity,
                child: OutlinedButton(
                  child: Text('ログイン'),
                    onPressed: () async {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      await auth.signInWithEmailAndPassword(
                        /* emailとpasswordでユーザー認証する */
                          email: email,
                          password: password,
                      );
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return DiaryList();
                        }),
                      );

                    },
              ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class DiaryModel extends StatelessWidget {
  /* 日記のモデル */
  String titletext = ''; // タイトル
  String bodytext = ''; // 本文
  File? image; // 画像
  String createtime = DateTime.now().toLocal().toIso8601String(); // 制作日
  String uid = ''; // ユーザーID

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


// TODO: class DiaryCreateの作成


// TODO: class DiaryDetailの作成


class DiaryList extends StatefulWidget {
  /* 日記一覧 */
   @override
  _DiaryListState createState() => _DiaryListState();
}

class _DiaryListState extends State<DiaryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('日記一覧'),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        /*日記投稿画面への遷移ボタン*/
        child: Icon(
          Icons.create,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Authy(),
          ));
        },
      ),


      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
        decoration: BoxDecoration(border: Border.all(
        color: Colors.red,
          width: 20.0,))
            )
          ],
        ),

      ),
    );
  }
}



