# 本番デプロイガイド

このドキュメントは、Streamlit Community Cloud へのデプロイと、本番運用の管理方法について説明しています。

## 本番URL化の3ステップ

### 1. Git と GitHub 設定

#### setup_git.bat を実行

```cmd
setup_git.bat
```

ユーザー名とメールアドレスを入力します。  
これは GitHub コミットの著者情報として使用されます。

### 2. GitHub リポジトリへ初期 Push

1. https://github.com/new で新規リポジトリを作成
2. リポジトリページから「Code」をクリックしてURLをコピー  
   例: `https://github.com/YOUR_USERNAME/kensa-analysis.git`
3. init_github_repo.bat を実行

```cmd
init_github_repo.bat
```

リポジトリURLを聞かれたら、コピーしたURLを貼り付けて Enter。

### 3. Streamlit Community Cloud でデプロイ

1. https://streamlit.io/cloud にアクセス
2. GitHub アカウントでログイン（なければ新規登録）
3. 「New app」をクリック
4. 以下を選択/入力:
   - Repository: YOUR_USERNAME/kensa-analysis
   - Branch: main
   - File path: app.py
5. 「Deploy」をクリック

完了後、`https://YOUR_APP_NAME.streamlit.app` の形式で本番URLが発行されます。

## 本番運用

### コード更新時の再デプロイ

ローカルで app.py や他のファイルを変更したら、push_to_github.bat で自動的に GitHub へプッシュされます。

```cmd
push_to_github.bat
```

コミットメッセージを入力して Enter。  
GitHub へプッシュが完了すると、Streamlit Cloud が自動再デプロイ（1～2分）。

### 本番URLの管理

発行された `https://YOUR_APP_NAME.streamlit.app` は以下の用途に共有します：

- 利用者への案内
- 社内ドキュメント
- メールテンプレート

この URL は変わらないため、ブックマークや QR コード化して利用できます。

### ログとトラブル対応

**アプリの様子を確認したい時:**

Streamlit Cloud ダッシュボード（https://share.streamlit.io）でアプリを選択 → 「Logs」タブで実行ログを確認

**デプロイが失敗した時:**

1. GitHub にコードが正しく Push されているか確認
2. requirements.txt に必要なパッケージがすべて記載されているか確認
3. app.py に構文エラーがないか確認
4. 上記で問題なければ、Streamlit Cloud ダッシュボードで再デプロイを試す

## 制限事項

- **ストレージ**: 無料プランは月1GB
- **実行時間**: 月30時間の実行制限
- **更新タイミング**: リアルタイムではなく、git push から1～2分のデプロイ時間

無制限で使用したい場合は、Streamlit Pro（有料）への登録を検討してください。

## セキュリティに関する注意

- **機密情報を commit しない**: API キーやパスワードは絶対に git に追加しない
- **.env ファイル**: 環境変数は `.streamlit/secrets.toml` で管理（Streamlit Cloud ダッシュボードで設定）
- **公開URL**: URLを知っていれば誰でもアクセスできるため、データ利用ルールを定める

## ローカル開発との使い分け

| 用途 | 実行方法 | 特徴 |
|------|---------|------|
| ローカル検証 | `open_app.bat` | 高速、テスト向け |
| 社内LAN共有 | `open_lan_app.bat` | 同一ネットワーク内のみ |
| インターネット公開（一時） | `start_public_url.bat` | PC起動中のみ、トンネル使用 |
| 本番公開（常設） | Streamlit Community Cloud | 常時公開、URL固定、最も安定 |

## 参考リンク

- [Streamlit Community Cloud 公式ドキュメント](https://docs.streamlit.io/deploy/streamlit-community-cloud)
- [GitHub 初心者向けガイド](https://docs.github.com/ja/get-started)
- [Streamlit 公式ドキュメント](https://docs.streamlit.io)
