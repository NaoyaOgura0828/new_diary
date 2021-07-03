import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';



final userProvider = StateProvider((ref) {
  /* Providerでユーザー情報の受け渡し有効化 */
  return FirebaseAuth.instance.currentUser;
});


final infoTextProvider = StateProvider.autoDispose((ref) {
  /* Providerでエラー情報の受け渡し有効化 */
  return '';
});


final emailProvider = StateProvider.autoDispose((ref) {
  /* Providerでメールアドレスの受け渡し有効化 */
  return '';
});


final passwordProvider = StateProvider.autoDispose((ref) {
  /* Providerでパスワードの受け渡し有効化 */
  return '';
});



final titleTextProvider = StateProvider.autoDispose((ref) {
  /* Providerで日記タイトルの受け渡し有効化 */
  return '';
});


final bodyTextProvider = StateProvider.autoDispose((ref) {
  return '';
});




final postsQueryProvider = StreamProvider.autoDispose((ref) {
  /* 日記投稿時間の受け渡し有効化 */
  return FirebaseFirestore.instance
      .collection('posts')
      .orderBy('date')
      .snapshots();
});



// TODO:Providerで画像(URL?)の受け渡し有効化





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      ProviderScope( // Riverpodでのデータを受け渡し有効化
        child: MyApp(),
      ),
  );
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
class DiaryCreate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    /* Providerから日記情報を受け取る */
    final user = watch(userProvider).state!;
    final titletext = watch(titleTextProvider).state;
    final bodytext = watch(bodyTextProvider).state;
    return Scaffold(
      appBar: AppBar(
        title: Text('日記作成'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              /* タイトルフォーム */
              decoration: InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
                // TODO:内部処理の記述

              ),
            ),


            const SizedBox(height: 8.0,),


            TextFormField(
              /* 本文フォーム */
              decoration: InputDecoration(
                labelText: '内容',
                border: OutlineInputBorder(),
                // TODO:内部処理の記述


              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                /* TODO:画像選択アイコンの作成 */
                FloatingActionButton(
                  child: Icon(
                    Icons.photo_library
                  ),

                  onPressed: null, // TODO:カメラロールにアクセスする

                ),

                ElevatedButton(
                  child: Text(
                    '投稿',
                  style: TextStyle(fontSize: 15.0),
                  ),

                  onPressed: null, // TODO:DiaryListへ遷移と同時に投稿
                )





              ],
            )


          ],
        ),

      ),
    );
  }
}











// TODO: class DiaryDetailの作成


class DiaryList extends ConsumerWidget {
  /* 日記一覧 */
   @override
   Widget build(BuildContext context, ScopedReader watch) {

     final User user = watch(userProvider).state!;
     final AsyncValue<QuerySnapshot> asyncPostsQuery = watch(postsQueryProvider);




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
                builder: (context) => DiaryCreate(), // DiaryCreateへ遷移
          ));
        },
      ),


      body: Column(
        children: [

          Expanded(

            child: asyncPostsQuery.when(
              /* 日記の読み込み状況による分岐 */


              data: (QuerySnapshot query) {
                /* 日記の読み込みに成功した場合 */
                return ListView(
                  children: query.docs.map((document) {
                    return Card(


                      child: ListTile(
                        title: Text(document['text']),
                        subtitle: Text(document['uid']),



                        trailing: document['email'] == user.email
                        /* メールアドレスでユーザーの確認を行いTrueならば削除ボタンを表示する */
                            ? IconButton(
                          icon: Icon(Icons.delete),
                          /* 投稿日記削除ボタン */
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('posts')
                                .doc(document.id)
                                .delete();
                          },
                        )
                            : null, // Falseの場合は表示しない
                      ),
                    );
                  }).toList(),
                );
              },

              loading: () {
                /* 日記読み込み中 */
                return Center(
                  child: Text('読込中...'),
                );
              },

              error: (e, stackTrace) {
                /* 日記読み込み失敗した場合 */
                return Center(
                  child: Text(e.toString()),
                );
              },
            ),

          ),
        ],
      ),



    );
  }
}



