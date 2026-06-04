# 外観検査分析システム（XLSX）

XLSXファイルを画面から都度選択して読み込み、
機種別・検査員別に不良傾向を分析するStreamlitアプリです。

このリポジトリは、以下の3パターンで利用できます。

- 個人PCでローカル利用
- 社内ネットワークで共有利用
- クラウドに公開してどこからでも利用

## できること

- 実行のたびにXLSXファイルを選択して分析
- 機種別の集計（検査件数、サンプル数、不合格数、不良率）
- 検査員別の集計（検査件数、サンプル数、不合格数、不良率）
- 不良率しきい値による課題候補の抽出
- 不適合項目（K3〜BX3）ごとの検出数ランキング
- 集計結果のExcelダウンロード（機種別/検査員別/不適合項目上位）

## 利用者向けクイックスタート

### インターネット公開URLを発行する（誰でもアクセス）

1. `start_public_url.bat` を実行
2. 画面に表示された `https://...trycloudflare.com` を共有
3. 停止する時は `stop_public_url.bat` を実行

補足:

- 初回は `cloudflared` を自動インストールします
- 公開URLはこのPCが起動中の間だけ有効です
- URLを知っている人は誰でもアクセスできるため、機密データは扱わないでください
- デスクトップショートカットは `create_public_shortcut.bat` で作成できます

### 本番URL化: 常時アクセス可能なURLを発行する

PCを閉じてもいつでもアクセスできる恒久的なURLが必要な場合は、Streamlit Community Cloud へデプロイします。

#### ステップ1: Git 初期設定

`setup_git.bat` を実行して、Git ユーザー名とメールアドレスを登録します。

```bash
setup_git.bat
```

#### ステップ2: GitHub リポジトリ作成

1. https://github.com/new にアクセス
2. Repository name: `kensa-analysis` など
3. Public を選択
4. Create repository

#### ステップ3: ローカルコードを GitHub に Push

`init_github_repo.bat` を実行します。  
リポジトリURL（https://github.com/YOUR_USERNAME/kensa-analysis.git）を入力すると、自動的に初期コミットと Push が行われます。

```bash
init_github_repo.bat
```

補足:

- 初回実行時、GitHub のログイン認証が求められます

#### ステップ3: Streamlit Community Cloud でデプロイ

1. https://streamlit.io/cloud にアクセス
2. GitHub でログイン（まだの場合は新規登録）
3. 「Create app」をクリック
4. 以下を指定:
   - Repository: `YOUR_USERNAME/kensa-analysis`
   - Branch: `main`
   - File path: `app.py`
5. Deploy をクリック

#### ステップ4: 本番URLを共有

デプロイ完了後、`https://YOUR_APP_NAME.streamlit.app` という固定URLが発行されます。  
このURLを利用者へ共有してください。

#### コード更新時の再デプロイ

`push_to_github.bat` を実行して、変更をコミット・プッシュします。

```bash
push_to_github.bat
```

コミットメッセージを聞かれたら入力してください。  
GitHub へのプッシュが完了すると、Streamlit Community Cloud が自動的に再デプロイします（1～2分）。

**マニュアルコマンド:**

```bash
git add .
git commit -m "Update analysis logic"
git push origin main
```

#### 注意事項

- 公開URLは誰でもアクセスできるため、機密情報のアップロード運用ルールを定めてください
- 無料プランは月1GBのストレージと限られた実行時間で制限があります
- 有料プランで専用ドメイン設定も可能です（Streamlit 側の有料プラン参照）

### どのアカウントでもブラウザ利用したい場合（推奨）

1. 管理者権限で `enable_firewall_8501.bat` を実行
2. 管理者権限で `install_startup_task.bat` を実行
3. （任意）`create_lan_shortcut.bat` を実行して起動ショートカット作成
4. ブラウザで `http://<このPCのIP>:8501` にアクセス

補足:

- これで `app.py` を開かなくても、PC起動後にサーバが自動起動します
- 同じPCの別アカウントからもブラウザでアクセス可能です
- 不要になったら `remove_startup_task.bat` で自動起動を解除できます

### 方法0: app.pyを開かずにブラウザ起動（推奨）

1. `open_app.bat` をダブルクリック
2. 起動済みならそのままブラウザ表示、未起動なら自動起動後にブラウザ表示

### デスクトップショートカット作成（推奨）

1. `create_desktop_shortcut.bat` を1回だけ実行
2. デスクトップの `KensaAnalysis` ショートカットをダブルクリック
3. `app.py` を開かずにブラウザで利用可能

補足:

- アプリ本体はバックグラウンドで起動します
- PC再起動後もショートカットから再起動できます

### ショートカットで開けない場合

1. 既存ショートカットを削除
2. `create_desktop_shortcut.bat` を再実行
3. `open_app.bat` を直接ダブルクリックして起動確認
4. 失敗時は `start_server.bat` を直接ダブルクリックして起動確認
5. ログファイル `logs/start_server.log` の内容を確認

### 方法1: ダブルクリックでローカル起動

1. `run_local.bat` をダブルクリック
2. ブラウザで `http://localhost:8501` が開いたら利用開始

### 方法2: 社内LANで共有起動

1. 管理者PCで `run_lan.bat` をダブルクリック
2. 同一ネットワークの利用者は `http://<管理者PCのIP>:8501` にアクセス

または `open_lan_app.bat` を使うと、未起動時は自動起動してURLを表示します。

補足:

- Windowsファイアウォールで8501ポートの受信許可が必要です
- 会社ネットワークのポリシーに従って公開範囲を設定してください

## 想定しているデータ配置

選択したシートから、以下のセル範囲を読み込みます。

- `B11:B105` : 検査員イニシャル
- `D11:D105` : 検査日
- `E11:E105` : 機種名
- `G11:G105` : ロット総数
- `H11:H105` : サンプル数
- `J11:J105` : 不合格数
- `K3:BX3` : 不適合項目名
- `K11:BX105` : 不適合項目ごとの検出数

## セットアップ

本番公開を予定されている場合は、まず [DEPLOY.md](DEPLOY.md) を読んでください。

### 1. 仮想環境の有効化（任意）

PowerShell:

```bash
.\venv\Scripts\Activate.ps1
```

### 2. 依存パッケージのインストール

```bash
pip install -r requirements.txt
```

## 起動

```bash
streamlit run app.py
```

または次のコマンドでも起動できます（内部でStreamlit起動に切り替わります）。

```bash
python app.py
```

ブラウザ画面の「分析対象のXLSXファイルを選択してください」から、
毎回対象ファイルを選択して読み込んでください。

## Dockerで配布・導入する

Dockerが使える環境なら、利用者端末にPython導入は不要です。

### イメージ作成

```bash
docker build -t kensa-analysis-app .
```

### コンテナ起動

```bash
docker run -d --name kensa-analysis -p 8501:8501 kensa-analysis-app
```

### アクセス

- ローカル: `http://localhost:8501`
- ネットワーク共有: `http://<サーバIP>:8501`

## クラウド公開（誰でもアクセス可能）

公開要件がある場合は Streamlit Community Cloud または社内クラウド基盤を推奨します。

### Streamlit Community Cloud の例

1. このプロジェクトをGitHubリポジトリにPush
2. Streamlit Community Cloudにログイン
3. 対象リポジトリと `app.py` を指定してデプロイ
4. 発行されたURLを利用者へ共有

注意:

- 公開URLはインターネットから閲覧可能です
- 機密データはアップロードしない運用ルールを定めてください

## 出力

画面下部の「集計結果をExcelで保存」ボタンから、
以下シートを含むExcelをダウンロードできます。

- `機種別集計`
- `検査員別集計`
- `不適合項目上位`
