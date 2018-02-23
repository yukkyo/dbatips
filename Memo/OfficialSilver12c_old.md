下記動画内で扱われていた問題集です。自分用に

[ORACLE MASTER Silver Oracle Database 12c 試験対策ポイント解説セミナー - YouTube](https://www.youtube.com/watch?v=MdpYA4gkNRs)

※ 試験範囲改訂前なので不要な部分もあります。
※ 2017年8月以降受験する人は鵜呑みにしないでください

# 目次

* 12c 試験概要
* ポイント解説

# 試験概要

Silver 以上は世界共通資格

# 出題範囲

## Oracle DB のインストール、アップグレード及びパッチ適用

* Oracle ソフトウェアのインストール基礎
* スタンドアロンサーバー用のOracle Grid Infrastructure のインストール
* Oracle DB ソフトウェアのインストール
* DBCA を使用して Oracle DB を作成する
* Oracle Restart の使用
* Oracle DB ソフトウェアのアップグレード
* Oracle 12c へのアップグレード準備
* アップグレード
* アップグレード後作業の
* Data Pump を使用したデータ移行

## Oracle DB の管理

* DB アーキテクチャ確認
* DB 管理ツール
* DB インスタンス
* ネットワーク環境の設定
* DB 記憶域構造の管理
* ユーザーセキュリティの管理
* 領域の管理
* UNDO データの管理
* データ並行性の管理
* Oracle DB 監査の実装
* バックアップとリカバリの概念
* バックアップとリカバリの設定
* DB のバックアップ実行
* DBのリカバリの実行
* データの移動
* DBメンテナンスの実行
* パフォーマンス管理
* パフォーマンス管理: SQL チューニング
* DBリソースマネージャの使用
* Oracle Schedulerの使用によるタスク自動化

出題範囲はサイトで確認できる

# 各練習問題(Oracle Database Install セクション)

※改訂後はこの部分はそこまで出ないと思われます

## 問1
### 問題
各種管理操作とその操作を行うための最適な管理権限の組み合わせとして正しいものを2つ選択してください

1. SYSDBA: 透過的データ暗号化のウォレット操作
2. SYSOPER: ASMインスタンスの起動・停止
3. SYSBACKUP: RMANを使用したバックアップ・リカバリ操作
4. SYSDG: Data Guard Broker による Data Guard 操作

### 解答
3,4(予想は 3,4)

※補足

* SYSDBA: インスタンスの起動停止、ARCHIVELOGモードの変更、リカバリ等のDBインスタンスの管理。ユーザーデータの表示も含む
* SYSOPER: インスタンスの起動・停止、ARCHIVELOGモードの変更等のDBインスタンスの管理
  * 日常的な管理操作のみに絞る
* SYSBACKUP: バックアップ・リカバリ操作
* SYSDG: Data Guard 操作
* SYSKM: 透過的データ暗号化のウォレット操作の管理
  * key management
* SYSASM: ASMインスタンスの管理
  * 11g から

## 問2
### 問題

Oracle Linux 6 上に Oracle DB をインストールしたい。Oracle RDBMS Pre-Install RPM について正しい説明を 2つ選択してください

1. Oracle DB をインストールするマシンに、必ず事前にインストールしておく必要がある
2. Oracle Grid Infrastructure のインストールに必要な追加パッケージを自動的にインストールする
3. Oracle DB のインストールに必要な追加パッケージを自動的にインストールする
4. Oracle インベントリ・グループである oinstall グループの作成は手動で行う必要がある



### 解答
2,3(予想は2,3)

※補足

* Oracle Grid Infrastructure および Oracle DB の install に必要な追加パッケージを自動的に install
* OSの構成
  * カーネルパラメータの設定
  * 以下の OS ユーザー、グループの構成
    * Oracle DB のインストール所有者である oracle
    * Oracle インベントリグループである oinstall
    * Oracle 管理権限グループである dba

## 問3
### 問題

サイレント・モードでのインストールについて正しい説明を1つ選択してください

1. サイレント・モードで使用するレスポンスファイルは、Oracle Universal Installer を使用して作成・編集するバイナリ・ファイルである
2. サイレント・モードで使用するレスポンスファイルは、テキストエディタで編集可能なテキストファイルである
3. サイレント・モードで Oracle DB をインストールする場合は $ORACLE_HOME/root.sh を実行する必要がない
4. DBCA や Oracle Net Configuration(NetCA) には、サイレント・モードは用意されていない

### 解答
2 (予想は2)

※補足(サイレントモードによるインストール・構成)

* 提供されるテンプレートをもとにレスポンスファイルを用意することでサイレントモードでインストール・構成を行える
* `./runinstaller -silent -responsefile <filename>`
* Oracle Universal Installer を対話モードで実行し、「サマリー」ページで「レスポンスファイルの保存」を行うことも可能
* ASMCA、DBCA、NetCAもサイレントモードで実行可能

## 問4
### 問題

Oracle Restart について正しい説明を 2つ選択してください

1. 単一インスタンス(非クラスタ)環境および Oracle Real Application Clusters(Oracle RAC)環境に対して高可用性ソリューションを実装する
2. Oracle Net リスナーは、Oracle Restart の監視対象コンポーネントである
3. Oracle Restart は Oracle DB ホームから実行される
4. Oracle Restart によるコンポーネントの起動は、コンポーネントの依存関係に基いて適切な順序で行われる

### 解答
2,4 (予想は2,4)

※ 補足(Oracle Restart)

* スタンドアロンサーバー用の Oracle Grid Infrastructure に含まれる
* 単一インスタンス(非クラスタ)環境のみに対して高可用性ソリューションを実装する
  * Oracle RAC 環境の場合は、Oracle Clusterware によって高可用性ソリューションが提供される
* 以下のコンポーネントを監視・再起動する
  * DB インスタンス
  * Oracle Net リスナー
  * DB サービス
  * ASM インスタンス
  * ASM ディスクグループ
* コンポーネントの依存関係に基づいて、適切な順序で起動・停止が行われる
  * 例: ASM上にDBを構成している場合は、ASMを起動してからDBを起動する

## 問5
### 問題

Oracle Restart の自動起動を有効化するコマンドを1つ選択してください

1. `$ crsctl config has`
2. `$ crsctl enable has`
3. `$ crsctl start has`
4. `$ srvctl config has`
5. `$ srvctl enable has`
6. `$ srvctl start has`

### 解答
2 (予想は5)

> CRSCTLはユーザーとOracle Clusterwareのインタフェースであり、Oracle Clusterwareオブジェクト用のOracle Clusterware APIを解析およびコールします。

has は high availability solution

※補足(Oracle Restart の制御)

* Oracle Restart は OS の initデーモンによって起動
* Oracle Clusterware Control(CRSCTL) ユーティリティを使用して Oracle Restart の状態を制御できる
  * `$ crsctl config has`: Oracle Restart の構成を表示
  * `$ crsctl {enable|disable} has`: Oracle Restart の自動再起動の有効化・無効化
  * `$ crsctl {start|stop} has`: Oracle Restart の起動・停止
* CRSCTL ユーティリティを使用して Oracle Restart を停止すると Oracle Restart 管理下のコンポーネントも停止される


## 問6
### 問題

Oracle Restart を使用しているケースで、メンテナンスのため ASM ディスクグループ "DATA" を停止する必要が生じた。停止手順として最適なものを 1つ選択してください

* 前提1: Oracle Grid Infrastructure ホームは `/u01/app/grid/product/12.1.0/grid` とする
* 前提2: Oracle DB ホームは `/u01/app/oracle/product/12.1.0/dbhome_1` とする

---

* 選択肢1

```bash
$ export ORACLE_HOME=/u01/app/grid/product/12.1.0/grid
$ $ORACLE_HOME/bin/srvctl stop diskgroup -g "DATA" -f
```
* 選択肢2

```bash
$ export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
$ $ORACLE_HOME/bin/srvctl stop diskgroup -g "DATA" -f
```

* 選択肢3

```bash
$ export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
$ $ORACLE_HOME/bin/srvctl stop database -d PROD -o normal
$ $ORACLE_HOME/bin/srvctl stop asm -o immediate -f
```

### 解答
1 (予想は2)

※補足(サーバー(SRVCTL)制御ユーティリティ)

* Oracle Grid Infrastructure ホームの SRVCTL により操作するコンポーネント
  * ASM インスタンス
  * ASM ディスクグループ
  * リスナー ※Oracle Grid Infrastructure を先にインストールした場合
* Oracle DB ホームの SRVCTL により操作するコンポーネント
  * DBインスタンス
  * DBサービス
* `srvctl stop diskgroup -g "DATA" -f` コマンドを実行すると、 DATA ディスクグループに依存するDBインスタンスが停止され、DATAディスクグループが強制的にアンマウントされる
* NetCA、DBCAなどを用いずに作成したコンポーネントは Oracle Restart の監視対象に自動的に追加されないので `srvctl sadd` コマンドで手動で追加する

## 問7
### 問題

データベースのアップグレードによって、SQL の実行計画にどのような影響が出るか、テストするための機能はどれですか。正しいものを1つ選択してください

1. データベース・アップグレード・アシスタント
2. データベース・リプレイ
3. SQL アクセス・アドバイザ
4. SQL パフォーマンス・アナライザ


### 解答
4(予想は3)

※ 11gからの追加
※ 補足(アップグレード前のパフォーマンステスト)

* データベース・リプレイ
  * 本番データベース上でのワークロードをキャプチャし、テスト環境上でリプレイしてパフォーマンスをテストすることが出来ます
  * テスト環境でのリプレイ後、リプレイ前の状態にデータを復元します
* SQL パフォーマンス・アナライザ
  * 用意した SQL チューニング・セットについて、リリースやパラメータ設定などを変更した場合に実行計画にどのような影響が出るか、テストすることが出来ます

## 問8
### 問題

Oracle Data Pump について正しい説明を 2つ選択してください

1. マスター表(MT)が保持されていれば、トラブルにより中断したデータ・ポンプ・ジョブは再開できる
2. マスター表(MT)が保持されていても、意図して停止されたデータ・ポンプ・ジョブは再開できない
3. ダンプ・ファイル・セットにはデータ・ファイルのみが含まれる
4. データベース・リンクを使用して、中間ダンプ・ファイル無しにデータベース全体をインポートすることができる

### 解答
1,4(予想は1,4)

※補足(Oracle Data Pump)

* マスター表が保持されていれば、中断したデータ・ポンプ・ジョブは再開可能
* ダンプ・ファイル・セットには、データおよびメタデータが含まれる
* データベース・リンクを使用したインポートも可能

# 各練習問題(Oracle Database の管理セクション)

## 問1
### 問題

リスナー登録プロセス(LREG)について正しい説明を1つ選択してください

1. LREG はリスナーの負荷状況をデータベース・インスタンスに提供する
2. LREG はセッション・ユーザーの情報をリスナーに提供する
3. データベース・サービス名およびそのサービスに関連付けられているデータベース・インスタンス名と、その負荷状況をリスナーに提供する
4. リスナー起動後、LREG によりデータベース・インスタンスの情報がリスナーに登録されるまで、最大 60 分掛かる

### 解答
3(予想は3)

※補足(リスナー登録プロセス)

* 従来はプロセスモニターによって動的登録が行われていた。11g からこれ
* DBインスタンスおよびディスパッチャプロセスに関する情報を Oracle Net Listener に登録する
* LREG からリスナーに以下の情報が提供される
  * データベース・インスタンス名
  * サービスに関連づかられたインスタンス名とその現在の負荷および最大負荷
  * サービス・ハンドラ(ディスパッチャおよび専用サーバー)のタイプ、プロトコル・アドレス、その現在の負荷および最大負荷
* リスナー起動後に LREG により動的登録されるまで、最大で 60秒かかる
* `ALTER SYSTEM REGISTER` コマンドにより手動で登録も可能

## 問2
### 問題

一時 UNDO について正しい説明を 3つ選択してください

1. インスタンス・リカバリの際に生成される UNDO データのこと
2. 一時表に対するトランザクションにより生成される UNDO データのこと
3. 一時 UNDO は一時表領域に格納される
4. 一時 UNDO は UNDO 表領域に格納される
5. 一時 UNDO は REDO ストリームに記録される
6. 一時 UNDO は REDO ストリームに記録されない

### 解答
2,3,6(予想は 2, 3, 6)

※補足(一時 UNDO のコンセプト)

* UNDO ストリームを永続・一時に分けることで、それぞれの保存モデルにより領域を節約できる
* 一時表へのトランザクションにより生成される UNDO
* UNDO 表領域ではなく一時表領域に格納
* REDO ストリームに記録しない
* 初期化パラメータ `TEMP_UNDO_ENABLED` を TRUE に設定して有効化。デフォルトは FALSE

## 問3
### 問題
以下のコメンドを発行した結果として正しいものを1つ選択してください

`ALTER SYSTEM SET LOG_BUFFER=64M;`

前提1: サーバー・パラメータ・ファイル(SPFILE) を使用してインスタンスを起動
前提2: 自動メモリ管理(AMM)を設定済

1. 自動メモリ管理を設定しているのでエラーとなる
2. パラメータ値が即時に変更され、再起動後もその値が維持される
3. `SCOPE=MEMORY` を設定していないのでエラーとなる
4. 動的に変更できないパラメータなのでエラーとなる

### 解答
4(予想は3)

※補足(REDOログ・バッファ)

* REDO ログ・バッファは自動メモリ管理の対象外
* 初期化パラメータ `LOG_BUFFER` で設定する。このパラメータは静的
* パラメータを変更するコマンド
  * `ALTER SYSTEM SET parameter_name = value [SCOPE = {BOTH|MEMORY|SPFILE}]`
  * デフォルトは `BOTH`
* 今回は `SCOPE=SPFILE` として、次回再起動時に反映させるなどする

## 問4
### 問題

DDL ログについて正しい説明を2つ選択してください

1. Oracle Database 12c では常に DDL ログが有効である
2. DDL ログはデータ・ディクショナリに書き込まれる
3. DDL ログは XML 版とテキスト版の2つの DDL ログ・ファイルに書き込まれる
4. CREATE/ALTER/DROP/TRUNCATE TABLE などの DDL ログがタイムスタンプとともに記録される

### 解答
3,4 (予想は3,4)

※アラートログファイルもXML版とテキスト版の両方あるよね
※補足(DDLログ)

* 初期化パラメータ `ENABLE_DDL_LOGGING` を TRUE に設定して有効化。デフォルトは FALSE
* ALERT LOG と同様のフォーマットで記録される(XMLファイルとテキストファイル)


## 問5
### 問題

Enterprise Manager Database Express について正しい説明を 2つ選択してください

1. EM Express から ARCHIVELOGモード、NOARCHIVELOGモードの切替えを行える
2. 複数のインスタンスが1つのマシン上で稼働している場合、1つの EM Express 画面で全インスタンスの情報を並べて表示できる
3. XMLDB サービス用のディスパッチャが必要である
4. DBCA で簡単に構成できる

### 解答
3,4(予想は 2,4)

※補足(EM Express)

* 軽量版の管理ツール
  * パフォーマンス監視
  * データベースの構成管理
  * 診断・チューニング
* XMLDB で使用できる組込みの Web サーバーを使用
* データベースが Open している時のみ使用可能
* 同一マシン上に複数インスタンス稼働している場合は、インスタンス毎に異なるポートを使用

## 問6
### 問題
以下の状況について、正しい説明を1つ選択してください

* DBA 権限を持つ "KANRI" というユーザーが CREATE USER システム権限を "JOHN" というユーザーに WITH ADMIN OPTION で与えた
* その後、"JOHN" は "BEN" というユーザーに CREATE USER システム権限を与えた
* その後、"KANRI" は "JOHN" から CREATE USER システム権限を剥奪しました

1. "BEN" も "JOHN" からの権限剥奪と同時に CREATE USER システム権限も失う
2. "JOHN" が作成したユーザーは権限剥奪と同時に削除される
3. "BEN" の CREATE USER システム権限はそのまま残る
4. WITH ADMIN OPTION ではなく、WITH GRANT OPTION である




### 解答
3(予想は1)

※補足(システム権限)

* 権限にはシステム権限とオブジェクト権限がある
* システム権限の付与
  * `GRANT priv TO username [WITH ADMIN OPTION]`
* システム権限の取り消し
  * `REVOKE priv FROM username`

## 問7
### 問題

ユーザーのパスワードについて正しい説明を3つ選択してください

1. Oracle DB 12c で作成したユーザーは、パスワードの大文字・小文字が区別される
2. Oracle DB 10g のデータベースを Oracle DB 12c にアップグレードした場合、パスワードを変更するまでは大文字・小文字は区別されない
3. パスワードを入力せずにデータベースに接続する方法がある
4. 全ユーザーのパスワードがパスワード・ファイルに格納される



### 解答
1,2,3 (予想は 1,2,3)

※補足(ユーザーの認証方式)

* パスワード認証
* 外部認証(OS, Kerberos, RADIUS)
* グローバル認証(LDAP)
* Oracle DB 11g 以降、パスワードの大文字・小文字を区別する
* それ以前のバージョンからのアップグレードの場合は、12c 上で変更するまでは大文字・小文字を区別されない
* パスワード・ファイルはインスタンスを起動する特権ユーザーの認証に使用する。それ以外の通常ユーザーのパスワードは含まない


## 問8
### 問題

高速リカバリ領域に格納するファイルを3つ選択してください

1. アーカイブ・ログ
2. フラッシュバック・ログ
3. フラッシュバック・データ・アーカイブ
4. UNDO
5. バックアップ
6. アラート・ログ

### 解答
1, 2, 5(予想は1, 2, 4)

※補足(高速リカバリ領域)

* バックアップ記憶域管理を簡略化できる
* DB_RECOVERY_FILE_DEST
* DB_RECOVERY_FILE_DEST_SIZE
* 格納されるファイル
  * バックアップ
  * アーカイブ・ログ
  * フラッシュバック・ログ
  * 制御ファイルや REDO ログファイルの多重化したコピー

## 問9
### 問題

通常は一定のしきい値ベースのアラートを設定して監視している。
例年、ゴールデンウィーク(GW)はアクセス傾向が異なるため、今年の GW は昨年の GW の実績をもとにしきい値を設定したい。どの機能を使用しますか

1. ADDM
2. AWR スナップショット・セット
3. AWR ベースライン
4. ASH

### 解答
3 (予想は 3)

※補足(AWR ベースライン)

* AWR スナップショットのセットで名前を付けたもの
* 過去の代表的な期間で設定
* ベースラインの値をもとにアラートのしきい値を設定可能
* 通常の AWR スナップショットはデフォルト 8日間でパージされるが、ベースラインにすると削除するまで保存できる

## 問10
### 問題

毎時 10分から20分まで(例 9:10〜9:20、10:10〜10:20)、パフォーマンスが劣化しているとの苦情が来た。調査したが、デフォルトの情報だけでは原因が分からない。今後、どのように分析すればよいか

1. STATISTICS_LEVEL 初期化パラメータを ALL に設定する
2. AWR の収集間隔を短く設定する(例えば 10分間隔)
3. TIMES_STATISTICS 初期化パラメータを 600に設定する
4. パフォーマンス・アナライザを 10分間隔で起動する

### 解答
2(予想は 2)

※補足(AWR)

* スナップショット間隔はデフォルトの60分から変更できます
* パフォーマンスの問題を検出できるように調整します
* メモリー内統計は MMON によって取得されます
* SYSAUX 表領域にデフォルトで 8日間保存されます

## 問11
### 問題

PGA の自動管理について正しい説明を1つ選択してください

1. PGA_AGGREGATE_LIMIT を設定しない場合、制限なく PGA に割当て可能である。
2. PGA メモリー合計量が PGA_AGGREGATE_TARGET を超えた場合、最もメモリを使用しているセッションでコールが終了される。
3. PGA_AGGREGATE_LIMIT は、使用可能な PGA メモリー合計量を厳密に制限する。
4. PGA メモリー合計量が PGA_AGGREGATE_LIMIT を超えた場合、各セッションの PGA メモリーの割当て量が調整される。

### 解答
3(予想は 4)

※補足(自動 PGA メモリー管理)

* PGA_AGGREGATE_TARGET で PGAメモリー合計量のターゲットを設定
* PGA_AGGREGATE_LIMIT で使用可能な PGA メモリー合計量を厳密に制限
* PGA_AGGREGATE_LIMIT の最低値は 1024 MB、最大値は物理メモリーから SGA の合計を引いた値の 120%
* PGA_AGGREGATE_LIMIT を設定していない場合のデフォルト値は PGA_AGGREGATE_TARGET の 200%
* PGA メモリー合計量が PGA_AGGREGATE_LIMIT を超えた場合は、メモリーを最も使用しているセッションが ORA-4036(SYS やバックグラウンドプロセスによるセッションは対象外)

**TARGET はあくまで目標値！**
