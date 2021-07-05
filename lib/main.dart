import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

import 'package:image_picker/image_picker.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uuid/uuid.dart';

final storage = FirebaseStorage.instance;

final storageRef = storage.ref();

final userProvider = StateProvider((ref) {
  /* Providerでユーザー情報の受け渡し有効化 */
  return FirebaseAuth.instance.currentUser;
});

final infoTextProvider = StateProvider.autoDispose((ref) {
  /* Providerでエラー情報の受け渡し有効化 */
  return '';
});

final postidProvider = StateProvider.autoDispose((ref) {
  /* Providerで投稿IDの受け渡し有効化 */
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
  /* Providerで日記本文の受け渡し有効化 */
  return '';
});

final postsQueryProvider = StreamProvider.autoDispose((ref) {
  /* 日記投稿時間の受け渡し有効化 */
  return FirebaseFirestore.instance
      .collection('post')
      .orderBy('postdate')
      .snapshots();
});

final imageUrlProvider = StateProvider.autoDispose((ref) {
  /* 画像URLの受け渡し有効化 */
  return '';
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      // Riverpodでのデータを受け渡し有効化
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  /* TODO:ここにまとめてProviderへ投げるものを記述して、以下ではConsumerWidgetは使用しない？  */

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
  String infotext = ''; // メッセージ表示

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
            children: <Widget>[
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
                obscureText: true, // パスワードを隠す
                onChanged: (String value) {
                  setState(() {
                    password = value; // passwordにパスワードを代入
                  });
                },
              ),
              Container(
                child: Text(infotext),
                padding: EdgeInsets.all(8.0),
              ),
              Container(
                /* ユーザー登録ボタン */
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('ユーザー登録'),
                  onPressed: () async {
                    try {
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
                    } catch (e) {
                      setState(() {
                        infotext = '登録に失敗しました : ${e.toString()}';
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                /* ログインボタン */
                width: double.infinity,
                child: OutlinedButton(
                  child: Text('ログイン'),
                  onPressed: () async {
                    try {
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
                    } catch (e) {
                      setState(() {
                        infotext = 'ログインに失敗しました : ${e.toString()}';
                      });
                    }
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

/* TODO:Firestoreに画像をStringで投げる */
class DiaryCreate extends StatefulHookWidget {
  /* 日記の作成 */

  @override
  _DiaryCreateState createState() => _DiaryCreateState();
}

class _DiaryCreateState extends State<DiaryCreate> {
  /* Providerから日記情報を受け取る */

  final picker = ImagePicker();

  File? _imageraw;

  Future getImageFromGallery() async {
    /* ギャラリーから画像を取得 */
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageraw = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = useProvider(userProvider).state!;
    final titletext = useProvider(titleTextProvider).state;
    final bodytext = useProvider(bodyTextProvider).state;
    final imageurl = useProvider(imageUrlProvider).state;
    final postid = useProvider(postidProvider).state;


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
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: TextStyle(fontSize: 20.0),

              /* Providerから日記タイトルを更新 */
              onChanged: (String value) {
                context.read(titleTextProvider).state = value;
              },
            ),
            const SizedBox(
              height: 8.0,
            ),
            TextFormField(
              /* 本文フォーム */
              decoration: InputDecoration(
                labelText: '内容',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: TextStyle(fontSize: 20.0),

              /* Providerから本文を更新 */
              onChanged: (String value) {
                context.read(bodyTextProvider).state = value;
              },
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        width: 100,
                        child: _imageraw == null
                            ? Text('写真を選んで下さい')
                            : Image.file(_imageraw!)), // イメージファイル読み込み表示
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton(
                  child: Icon(Icons.photo_library),
                  onPressed: getImageFromGallery, // カメラロールにアクセスする
                ),
                ElevatedButton(
                  /* 投稿ボタン */
                  child: Text(
                    '投稿',
                    style: TextStyle(fontSize: 15.0),
                  ),
                  onPressed: () async {
                    /* Firebase Storageへ投稿 */
                    Reference ref =
                        storage.ref().child('postimage').child(_imageraw!.path);
                    TaskSnapshot snapshot = await ref.putFile(_imageraw!);

                    final postimageurl = await snapshot.ref.getDownloadURL();
                    var imageurl = postimageurl.toString();

                    final postdate = DateTime.now().toLocal().toString();
                    final email = user.email;
                    final uid = user.uid;


                    final randomid = Uuid();
                    var postid = randomid.v4();



                    await FirebaseFirestore.instance
                        /* Firestoreへpostする日記データ */
                        .collection('post')
                        .doc()
                        .set({
                      'titletext': titletext,
                      'bodytext': bodytext,
                      'email': email,
                      'postdate': postdate,
                      'uid': uid,
                      'imageurl': imageurl,
                      'postid': postid, // ランダム文字列をpostidとする
                    });
                    Navigator.of(context).pop(); // 日記一覧画面へ戻る
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

/* TODO: 日記を選択した1枚だけ詳細表示する。レイアウトを整える */
class DiaryDetail extends HookWidget {
  /* 日記内容 */
  @override
  Widget build(BuildContext context) {
    final AsyncValue<QuerySnapshot> asyncPostsQuery =
        useProvider(postsQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('日記内容'),
        centerTitle: true,
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
                      child: Column(
                        children: <Widget>[
                          Card(
                            /* 投稿日時 */
                            child: Text(document['postdate']),
                            color: Colors.red,
                          ),
                          Card(
                            /* タイトル */
                            child: Text(document['titletext']),
                            color: Colors.blue,
                          ),
                          Card(
                            /* 本文 */
                            child: Text(document['bodytext']),
                            color: Colors.green,
                          ),
                          Card(
                            /* 画像 */
                            child: Stack(
                              children: [


                                Image.network(document['imageurl']),

                              ],
                            ),
                          ),
                        ],
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
          ElevatedButton(
            child: Text('一覧に戻る'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class DiaryList extends HookWidget {
  /* 日記一覧 */

  @override
  Widget build(
    BuildContext context,
  ) {
    final User user = useProvider(userProvider).state!;
    final AsyncValue<QuerySnapshot> asyncPostsQuery =
        useProvider(postsQueryProvider);


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
              )




          );
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
                      /* 日記の要約 */

                      child: ListTile(
                        /* DiaryDetailへ遷移 */
                        title: TextButton(
                          onPressed: () async {



                            /* TODO: postdoclistにdocument.idを代入して画面遷移時に呼び出したい */
                            /*List postdoclist = [];*/



                            /* TODO: 旧コードコメントアウト */
                            /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DiaryDetail(),
                                ));*/


                            /* TODO: Firestoreからdocumentのidを取得 */
                            await FirebaseFirestore.instance
                                .collection('post')
                                .doc(document.id).get()/*.then((value) => postdoclist.add(document.id))*/;


                                /* TODO: 実際に画面遷移する為の処理 */
                            Navigator.of(
                                context).push(
                                MaterialPageRoute(
                                builder: (context) => DiaryDetail()
                            ));
                            








                          },
                          child: Text(
                            document['titletext'],
                            style: TextStyle(fontSize: 30),
                          ),
                        ),

                        leading: Text(document['postdate']),
                        subtitle: Text(document['uid']),

                        trailing: document['email'] == user.email
                            /* メールアドレスでユーザーの確認を行いTrueならば削除ボタンを表示する */
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                /* 投稿日記削除ボタン */
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('post')
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
