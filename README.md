# 医療情報技師学習アプリ (IryojohoMaster)

**⚠️ 注意: このアプリケーションは現在開発中です。**

## 概要

医療情報技師の資格取得を目指す方のための学習支援アプリケーションです。効率的な学習管理と進捗追跡機能を提供し、医療情報技師試験に向けた体系的な学習をサポートします。

## 主な機能

- 🎯 問題演習機能：医療情報技師試験の出題傾向に基づいた問題演習
- 📊 学習進捗の可視化：カテゴリ別の習熟度グラフと学習履歴
- 📈 成績分析：正答率や苦手分野の分析
- 🔄 学習履歴の記録：学習セッションの記録と復習機能
- 📱 マルチプラットフォーム対応：iOS/Android/WebからのアクセスをサポートStful
- 🔐 ユーザー認証：Supabaseを利用したアカウント管理
- 💾 オフライン対応：インターネット接続がない環境でも学習可能

## アプリケーション構成

このアプリケーションは以下のアーキテクチャに基づいて構築されています：

- **UI/UX**: Flutter/Dart
- **状態管理**: flutter_bloc
- **バックエンド**: Supabase
- **データ永続化**: sqflite (ローカルデータベース)

## システム要件

- **Flutter SDK**: ^3.7.2
- **Dart SDK**: ^3.7.2
- **OS**: Android 5.0+、iOS 12.0+、Web、Windows、macOS、Linux

## 開発環境のセットアップ

1. リポジトリのクローン
```bash
git clone https://github.com/yourusername/IryojohoMaster.git
cd IryojohoMaster
```

2. 依存関係のインストール
```bash
flutter pub get
```

3. Supabase環境の設定
   - Supabaseプロジェクトを作成し、APIキーとURLを取得
   - プロジェクトのルートに`.env`ファイルを作成し、以下の内容を追加：
   ```
   SUPABASE_URL=あなたのSupabase URL
   SUPABASE_ANON_KEY=あなたのSupabase匿名キー
   ```

4. アプリを実行
```bash
flutter run
```

## プロジェクト構造

```
lib/
├── app/                  # アプリの全体設定
├── core/                 # 共通ユーティリティ、例外処理
├── data/                 # データソース、リポジトリ実装
│   ├── datasources/      # APIとローカルデータソース
│   ├── models/           # データモデル
│   └── repositories/     # リポジトリ実装
├── domain/               # ビジネスロジック
│   ├── entities/         # ドメインエンティティ
│   └── repositories/     # リポジトリインターフェース
└── presentation/         # UI層
    ├── blocs/            # BLoCパターンの状態管理
    └── pages/            # アプリの画面
```

## 使用している主なパッケージ

- **状態管理とデータ**
  - flutter_bloc: ^8.1.4
  - supabase_flutter: ^2.3.4
  - equatable: ^2.0.5
  - connectivity_plus: ^5.0.2
  - sqflite: ^2.3.2

- **UI components**
  - flex_color_scheme: ^7.3.1
  - adaptive_navigation: ^0.0.9
  - fl_chart: ^0.66.2
  - percent_indicator: ^4.2.3
  - flutter_markdown: ^0.6.21
  - table_calendar: ^3.0.9

## 開発状況

現在アクティブに開発中で、以下の機能を実装/改善中です：

- [ ] Supabaseを使用したユーザー認証システムの完成
- [ ] 問題データベースの拡充
- [ ] 学習分析機能の強化
- [ ] オフライン対応の改善
- [ ] UIデザインの最適化
- [ ] ユーザーインターフェースの多言語対応

## 貢献方法

1. このリポジトリをフォーク
2. 新しいブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 開発者向け情報

### コーディング規約

- Dartの公式スタイルガイドに従う
- BLoCパターンを使用して状態管理を行う
- リポジトリパターンを使用してデータアクセスを抽象化

### テスト

```bash
flutter test
```

### ビルドと配布

```bash
# Android向けリリースビルド
flutter build appbundle

# iOS向けリリースビルド
flutter build ipa

# Web向けリリースビルド
flutter build web
```
