# はじめに

最近FlutterとFirebaseを使ってWebアプリを作る機会があったので，その中で困った部分を記載します．Flutterも，Firebaseも業務で触るのは初めてで，色々手探りの中アプリを作成中です．

# お題

Flutterで作ったコードをFirebase Hostingする際，dev環境と本番環境それぞれにデプロイしたいと考えています．`firebase deploy --project=<プロジェクト>`だけでは，Hosting先が変わるのみで，Remote Configなどのサービスは，コード内で指定したFirebaseのプロジェクトを参照してしまいました．
そこで，コードを修正することなくデプロイ先の環境を切り替え，その環境のサービスを利用する対応を行ないます．今回はRemote Configを使って，それぞれの環境に変数を登録しておき，環境に応じてその値を用いるシーンを考えます．


# 結論

今回envファイルを用いて，Firebaseの初期化とビルドを切り替えるようにしています．Firebaseの初期化も環境によって切り替えることで，それぞれのRemote Configに登録している変数を参照することができるようになります．
(`flutter create myapp`や`firebase init`を実行済みで，ここでの記載は省略します．)

## ビルド時にenvファイルを切り替える

ビルドコマンド時に，定義ファイルを指定するようにします．`dev.env`，`prod.env`それぞれにAPI keyなど，Firebaseの初期化に必要な値を入れます．

```bash
flutter build web --dart-define-from-file=dart_files/prod.env
```

```example.env
apiKey=xxxxxx
authDomain=xxxxxx
projectId=xxxxx
storageBucket=xxxxx
messagingSenderId=xxxxx
appId=xxxxxxx
```



### Firebaseの初期化

envファイルに記載した値を用いて初期化します．

```dart:main.dart
void main() async {
  const apiKey = String.fromEnvironment('apiKey');
  const authDomain = String.fromEnvironment('authDomain');
  const projectId = String.fromEnvironment('projectId');
  const storageBucket = String.fromEnvironment('storageBucket');
  const messagingSenderId = String.fromEnvironment('messagingSenderId');
  const appId = String.fromEnvironment('appId');

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId
    ),
  );
  runApp(const MyApp());
}
```

## デプロイするプロジェクトを指定

`.firebaserc`を手動で修正し，`projects`に，prod環境とdev環境を定義します．
そして，デプロイ時にプロジェクトを指定して，デプロイするプロジェクトを切り替えます．

```json:.firebaserc
{
  "projects": {
    "default": "myapp-prod",
    "dev": "myapp-dev"
  }
}
```

```bash
firebase deploy --project=dev
```


# 結果

Remote Configから読み取った変数`env`をそのまま表示するWebアプリです．それぞれ登録しておいた`env`の値を表示してくれています．

## production環境でのHosting

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3618319/230e75ac-590d-59ae-0ba2-7326dbbe5bd0.png)


![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3618319/2135f57f-f38a-66cf-2360-c15012c86ec7.png)

## development環境でのHosting

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3618319/313a85e4-e074-897a-9e7d-0ce2e5639316.png)


![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3618319/f625a8c8-d2f1-bcc9-5a0e-8d27fde096d8.png)


# まとめ

今回はFirebaseのHosting環境に応じて，そこで使うためのサービス含めて切り替えることを検討しました．上記のように実現しましたが，正直ベストプラクティスなのかわかっていません．一案としてご参考になれば幸いです．


# 余談

ローカルでの確認では，Remote Configから値を読み取ることができるのに，Hostingすると値を読み取ることができない状況に陥ることがありました．結論としては，
```bash
flutter clean
```
をしてから，ビルドとデプロイをすれば解決しました．たったこれだけのことに苦労しました．


# 参考
- [FirebaseでStagingとProduction環境を切り替える](https://qiita.com/zaburo/items/8b926cb95fb0127f3203)
- [Firebase Hostingで開発環境と本番環境を分ける](https://zenn.dev/hanri/articles/1499858c0493ce)
- [Firebaseで開発環境と本番環境を分けたい](https://zenn.dev/captain_blue/articles/how-to-separate-firebase-dev-env)