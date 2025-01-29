## Wizub
Wizub（ウィザブ）は、「自分の好きなYouTube動画」を「日本語＋英語字幕の二重字幕」で、英語学習できるアプリです。

## サービスのURL
https://apps.apple.com/jp/app/wizub-%E5%AD%97%E5%B9%95-%E5%8B%95%E7%94%BB%E3%81%A7%E8%8B%B1%E8%AA%9E%E5%AD%A6%E7%BF%92/id6714475358

## サービスへの想い
プログラミングに出会ってから、昔に1年以上愛用していた英語学習アプリの機能の素晴らしさに改めて感動し、同じような機能をいつか自分の手で作りたいと思っていました。同時に、そのアプリで不便に感じた点を改善したいという思いもありました。

## サービスの概要
このアプリでは、ユーザーは英語学習に使用したい動画を自由に検索し、選ぶことができます。
また、動画の再生に連動して、動画内の細かいシーンごとに対応した英語字幕＆AIで翻訳された日本語字幕がリアルタイムで画面にリスト表示されていきます。

「動画のシーン、音声、二重字幕」これらが同時に連動することで、より直感的に英語を理解することができ、自分の興味のある動画を通じて、より楽しい英語学習を実現できます。
## 機能一覧

| **認証画面**                                                                                   | **動画検索画面**                                                                                   | **勉強画面１**                                                                                   |
|--------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| ![Image 1](https://github.com/user-attachments/assets/805c9c26-e314-4bc6-9d7f-ab54e2b489c0)      | ![Image 2](https://github.com/user-attachments/assets/4ba8339a-188d-4702-9ffd-ac046a7dfd12)      | ![Image 3](https://github.com/user-attachments/assets/6ae602e1-133b-4425-8cd4-8321304383ce)      |
| シンプルな認証機能と登録せずにアプリをお試しいただくためのトライアル機能を実装しました。| YouTube動画検索機能を実装しました。| 英語字幕の取得&表示機能、動画の再生速度変更、ポーズ、リピート、動画＆字幕の保存機能等を実装しました。|

| **勉強画面２**                                                                                   | **勉強画面３**                                                                           | **保存動画一覧画面**                                                                             |
|------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| ![Image 4](https://github.com/user-attachments/assets/2020b344-7331-43d9-814e-51adab75f9b5)      | ![Image 5](https://github.com/user-attachments/assets/e7e69fa3-77ab-4989-b62d-6a68b0e59c14)    | ![Image 6](https://github.com/user-attachments/assets/b9c59ac6-da32-408c-8d4f-3c4e310b1782)    |
| ChatGPTを活用した英語字幕の翻訳機能を実装しました。AIを駆使し、より自然な日本語訳を目指します。| それぞれのシーンに対応する字幕の編集機能、学習メモ機能を実装しました。| 保存した動画を一覧に表示し、復習することができます。|

## デモ動画（30秒）

https://github.com/user-attachments/assets/8346b0fd-dee0-4318-8137-b235fc860b3e

## 使用技術

### **フロントエンド**

- **Swift 5.10**
- **SwiftUI**
- **Combine（MVVM）**
- **YouTubePlayerKit 1.9.0**

### **バックエンド**

- **PHP 8.3**
- **Laravel 10.48.25**
- **Laravel Sanctum 3.3**
- **Python 3.12.6**

### **ネットワーク**

- **Alamofire 5.9.1**

### **データベース・ローカル環境**

- **MAMP 6.9**
    - **MySQL 5.7.39**

### **API**

- **Google API Client 2.18.2（YouTube動画の取得）**
- **YouTube Transcript API 0.6.2（YouTube動画字幕の取得）**
- **OpenAI API 0.28.0（ChatGPTによる翻訳に利用）**

### **バージョン管理**

- **Git**
- **GitHub**
- **SourceTree**

### **デプロイ**

- **Heroku**

### **パッケージ管理**

- **Swift Package Manager**
- **CocoaPods**

### その他

- **Postman**

## ER図

![image](https://github.com/user-attachments/assets/3570a9d5-04b3-4eaf-a9ee-fd5ae7ca1679)

## 英語字幕の翻訳機能フロー
##### 〜 AIを利用して、いかにして翻訳精度を上げ、かつ適切なJSONフォーマットでレスポンスを返却できるか 〜
### 簡易図⬇︎
![wizub-app-backend-なぜChatGPT？ drawio](https://github.com/user-attachments/assets/28173b24-3f8f-4c54-af30-5fe1c59f0bbc)

### 詳細図⬇︎
![wizub-app-backend-JSON2 drawio (1)](https://github.com/user-attachments/assets/a013fadc-8451-466f-888b-f90fdffe8cd1)
