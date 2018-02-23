問題を解いたり教科書読んだときのポイント
カッコの中は章と問題番号

# 解答テクニック

* 消去法
  * 消去法で明らかに違う選択肢を外す
    * 常に～
    * 必ず～
    * ～する必要がある
    * ～することがある
    * ～する場合もある
  * 苦し紛れの選択肢もある
* 英語に訳す
  * 選択肢がどれも選べない時、問題の意味がしっくりこない時は英語に訳して考える
    * または -> or
    * いずれか -> any
    * 表を記述すると -> 表を DESCRIBE(SQL*Plus DESCRIBE コマンド)すると
    * DB を開く/閉じる/非マウントする -> DB を OPEN/CLOSE/NOMOUNT にする
    * 復元する -> restore する
    * から -> from
* 複数選択
  * 例: ～するには何をしますか。3つ選択してください。
    * a
    * b
    * c
    * d
    * e
  * A & B、A & C (B & C はない)といったケースで、他の候補がなければ、A,B,C の3つを選択
* 受験時のポイント
  * コマンドとその出力(エラーメッセージ含む)、ディクショナリの問い合わせ結果での出題は注意深く読む
  * 似た問題が出てくることがあるので、不安な問題は保留しておいて、また後で見直す

# 受験にあたって

以下のマニュアルに目を通すと理解が深まる

* 管理者ガイド
* Oracle Database 概要
* Oracle Database アップグレードガイド



# Data Pump

* 12c ～ 全体トランスポータブル・エクスポート/インポート(フル・トランスポータブル・エクスポート/インポート)
  * Data Pump エクスポート/インポート の操作性とトランスポータブル表領域の迅速さを統合した機能
  * 11g R2 以降のデータベースを 12c のマルチテナント・アーキテクチャに移行するための機能
  * データベース・リンク経由のインポート(NETWORK_LINK)


# STATISTICS_LEVEL パラメータ

* STATISTICS_LEVEL
  * BASIC, TYPICAL, ALL
  * BASIC は AWR とかない
* AWR スナップショットによる分析
  * ADDM
  * カスタム ADDM
  * ベースライン
* サーバー生成アラート
  * DBA_OUTSTANDING_ALERTS : DBで未処理のアラート
  * DBA_ALERT_HISTORY : 消去されたアラートの履歴

# 自動化メンテナンス・タスク

* 自動化メンテナンス・タスク
  * 事前定義のタスク
    * 自動オプティマイザ統計収集
    * 自動セグメント・アドバイザ
    * 自動 SQL チューニング・アドバイザ
      * SQL プロファイルのみ自動実装可能
* メンテナンス・ウィンドウ
  * DBMS_SCHEDULER



# SQL ○○○○ アドバイザの違い
* SQL アクセスアドバイザ
  * 特定のワークロード(実際/仮想)に関してパフォーマンス目標の達成を支援
    * Bツリー索引、ビットマップ索引、ファンクション索引
    * MV、MVログ
    * パーティション化
* SQL チューニングアドバイザ
  * 高負荷 SQL のパフォーマンス問題を解決
    * オブジェクト統計の収集
    * 索引の作成
    * SQL リライト
    * SQL プロファイルの作成
    * SQL 計画ベースラインの作成
* SQL パフォーマンスアナライザ
  * システム変更による SQL パフォーマンスへの影響を分析


# リソース・マネージャとプロファイルによるリソース制限の区別

## リソース・マネージャによる制限

* CPU
  * 管理属性
  * 使用率制限
* Exadata I/O
* パラレル実行サーバー
  * 並列度制限
  * パラレル・サーバー制限
  * パラレル・キューのタイムアウト
* リソース集中型の問い合わせ
  * コンシューマグループの自動切り替え
  * SQL の取り消しとセッションの終了
  * 実行時間制限
* キューイングを備えたアクティブ・セッション・プール
  * UNDO プール
    * コミットされていないトランザクションに対する UNDO 合計量を制御する。 UNDO 制限を超えると、その UNDO を生成している現行の DML 文が終了し、他のメンバーは UNDO 領域がプールから解放されるまで新たに DML 文を実行できない。
  * アイドル時間制限
    * アイドル状態のまあｍいられる時間(セッションが終了されるまでの時間)
    * アイドル状態で他のセッションをブロックしているセッションに適用されるアイドル時間
  * 単純なリソースプランの作成
* UNDO プール
* アイドル時間制限


## プロファイルによるリソース制限

[CREATE PROFILE](https://docs.oracle.com/cd/E82638_01/SQLRF/CREATE-PROFILE.htm)

```sql
CREATE PROFILE
  --[resource_parameters] [integer | UNLIMITED | DEFAULT]
  SESSIONS_PER_USER
  CPU_PER_SESSION -- 100分の1秒
  CPU_PER_CALL -- 解析、実行、またはフェッチ、100分の1秒
  CONNECT_TIME -- 分単位
  IDLE_TIME
  LOGICAL_READS_PER_SESSION
  LOGICAL_READS_PER_CALL
  COMPOSITE_LIMIT -- 1セッションあたりのリソース総コスト。サービス単位で指定。
  PRIVATE_SGA --[size_clause | UNLIMITED | DEFAULT]
  --[password_parameters]
```


# スケジューラ・ジョブ

* ジョブチェーン
  * 前の 1 つ以上のジョブの結果に応じて異なるジョブを開始する依存性スケジューリングを実装するための手段
* 11gR2 ～ File Watcher
  * ファイルがシステムに到着したタイミングでスケジューラによりジョブを開始させる用途
  * 使い方
    * File Watcher オブジェクトを定義
    * File Watcher を参照するイベント・ベースのジョブを作成
    * 到着イベントによりジョブが開始
* 軽量ジョブ
* リモート・データベースにおけるジョブのスケジューリング
* スケジューラとリソース・マネージャの連携

# SQL Developer ができることできないこと(2-3)

SQL Developer は DB 作成はできない。
できるのは以下のようなもの

* RMAN バックアップ/リカバリ
* DB 起動
* Data Pump インポート/エクスポート

# SQL*Loader(2-3)

csv や テキストを高速ロード

1. CSV, Text 作成
2. 制御ファイル作成
3. コマンド実行 `SQLLDR USERID=scott/tiger, CONTROL=sample.ctl`

* sample.ctl の内訳

```sql
LOAD DATA
INFILE 'filename.csv'
INTO TABLE EMP
APPEND
FIELD TERMINATED BY ','
(EMP_ID, EMP_...)
```

# SPFILE のロード(3-1)

デフォルトでは「SPFILESID.ora → SPFILE → PFILE」で検索
PDB と CDB　では `CREATE SPFILE FROM MEMORY` の挙動が違う。
CDB では名前を変えないと再作成できない。PDBはできる。
PDB は内部的に格納する。

# アラートログ(3-5)

* アラートログ
  * 破損ブロック(ORA-01578)
  * 共有メモリエラー(ORA-04031)
  * 物理構造変更 SQL
  * ログスイッチやアーカイブログの作成時刻
  * インスタンスリカバリ + クラッシュリカバリ情報
  * デッドロック情報
  * 不完全なチェックポイント(未完了のチェックポイントによるREDOからの上書き)
  * チェックポイントの開始時刻と終了時刻
  * `ALTER SYSTEM` による変更
  * オブジェクトに対する `DROP, TRUNC` は**含まれない**

# DICTIONARY ビューについて(問題3-6)

* DICTIONARYビュー(DICT シノニム)は現 session でアクセス可能なディクショナリビューと v\$ビューの一覧
* v\$ビューの基礎表(固定表)の一覧を確認するには v\$FIXED_TABLE を参照

# DDL ログ(3-8)

* `ENABLE_DDL_LOGGING` を TRUE にすればとれる
* 自動診断レポジトリ
  * テキストと XML の両形式がある
* ユーザーの作成や変更、権限付与や取り消しは **記録されない**

# sqlnet.ora(4-1)

* sqlnet.ora : 名前解決(ネーミングメソッド)、暗号化などの設定
  * `NAMES.DIRECTORY_PATH=(方法1, 方法2,...)`
  * 方法は以下の通り
    * TNSNAMES, EZ_CONNECT, LDAP(ディレクトリサーバー)
* tnsnames.ora : ネット設定

# ネーミングメソッド(4-2)

* 簡易接続
  * プロトコルは TCP/IP のみ。`sqlplus username/password@` で接続するやつ
* ローカルネーミング
  * クライアント側の tnsnames.ora を使用
  * @ネットサービス名 で使用
  * 各種プロトコルや failover, loadbalance 使用可能
* ディレクトリネーミング
  * ディレクトリサーバー使用(LDAP)
  * sqlnet.ora に `NAMES.DIRECTORY_PATH=LDAP` が必要
* 外部ネーミング
  * 外部サーバー(NIS) 使用
  * sqlnet.ora に `NAMES.DIRECTORY_PATH=NIS` が必要

# Oracle Net Configuration Assistant, NETCA(4-3)
以下のことが設定できる

* リスナー構成
  * リスナーの追加、削除、名前の変更を listener.ora に保存
* ネーミング構成
  * 使用するネーミングメソッド(NAMES.DIRECTORY_PATH) を sqlnet.ora に保存
* ローカルネットサービス名構成
  * ネットサービス名と接続記述子の対応付けた情報を tnsnames.ora に保存
* ディレクトリ使用構成
  * ディレクトリサーバーを使用するための ldap.ora ファイルの構成

# 静的サービスと動的サービス(4-4)

* 静的サービス
  * listener.ora に接続先 DB サービスを明示的に記述
* 動的サービス
  * 各インスタンスは動的にリスナーに DB サービスを登録できる
  * 11g までは **PMON**、 12c からは **LREG** バックグラウンドプロセスが登録

# tnsping(4-8)

指定したネットサービス名や接続記述子でリスナーまでの接続確認
もちろんポートなども一致してないと通らない。
ただし sqlplus などの接続は、インスタンスが起動していなかったりリスナーにサービス登録されていないとできない。

# 専用サーバー接続(4-9)

* tnsnames.ora の接続記述子に `SERVER=DEDICATED` で専用サーバー接続
* 共有サーバー接続でできないこと
  * 起動や停止などの管理
  * RMAN を利用したバックアップとリカバリ

# DB リンク(4-10)

以下の `CURRENT_USER` は現セッションのグローバルユーザー(ディレクトリサーバーを利用したエンタープライズユーザー)

```sql
CREATE PUBLIC DATABASE LINK tablename
  CONNECT TO CURRENT_USER USING 'REPORT'
```

# 特権(5-2)

* SYSOPER
  * DB の起動停止、基本バックアップとリカバリ、ARCHIVELOGモード変更
* SYSDBA
  * SYSOPER + DB作成 + PITR(Point-in-time リカバリ)、すべてのディクショナリアクセス

# システム権限とオブジェクト権限(5-4)

* システム権限
  * `CREATE TABLE` や `CREATE SESSION` などの権限
  * `GRANT <権限> TO <user> WITH ADMIN OPTION` で渡されたユーザーは他に渡せる
  * 他の `ADMIN OPTION` があるユーザーなら誰でも消せる
  * **連鎖しない**
* オブジェクト権限
  * あるオブジェクトへのアクセス権限
  * `WITH GRANT OPTION` で他のユーザーにも権限付与できる
  * **付与したユーザーしか** 消せない(孫とかもだめ)
  * **連鎖する**

# 権限分析(5-5)

* `DBMS_PRIVILEGE_CAPTURE` パッケージを利用
* 以下の手順でレポート取得
  * `ENABLE_CAPTURE` で開始
  * 通常の SQL 操作
  * `DISABLE_CAPTURE` で取得終了
  * `GENERATE_RESULT` でレポート取得
    * 無効化しただけではレポートは生成されない

# リソース制限(5-7)

`RESOURCE_LIMIT=TRUE` の場合に適用される

# プロファイルを生成するファンクション(5-9)

* `$ORACLE_HOME/rdbms/admin/utlpwdmg.sql` でプロファイル生成できる
* 12c では以下のプロファイルが作成される
  * `ora12c_verify_function`
  * `ora12c_strong_verify_function`
  * 教科書だと以下も生成されるらしいが未確認
    * `VERIFY_FUNCTION_11G`
    * `VERIFY_FUNCTION`
* SYS ユーザーで実行する
* **SYS ユーザー以外に適用される**

# セグメント(6-1)

* セグメントはエクステントの集合
* `UNIFORM` 句で均一なサイズのエクステント
  * 大きいサイズも OK
  * 指定しない場合は 64k から始まる可変エクステント

# Oracle Managed Files, OMF (6-3)

DB 内のファイルを直接管理する必要を無くす機能

* ファイルを格納するディレクトリ指定
* DB ファイル作成時に自動で物理ファイル名指定
* DB ファイル作成時に自動で物理ファイル削除
  * ただし作成後に勝手に名前変えたら無理
* ASM では内部的に OMF が使用される
* DATAFILE 作成時にサイズ等を指定しなければ　100M の自動拡張が適用される

以下の初期化パラメータ設定

* `DB_CREATE_FILE_DEST`
  * データファイルと一時ファイルの保存場所
* `DB_CREATE_ONLINE_LOG_DEST_n`
  * 制御ファイルと REDO ログファイルの格納場所
  * 指定しなければ `DB_CREATE_FILE_DEST` と同じ場所
  * n は 1から5の値が入り、複数ディレクトリにミラー化できる
* `DB_RECOVERY_FILE_DEST`
  * 高速リカバリ領域
  * 指定しなければ `DB_CREATE_FILE_DEST` と同じ場所

# 断片化(7-3)

以下の方法がある

* Data Pump エクスポート/インポート
  * インポート完了まで表へのアクセスができない
* ALTER TABLE ... MOVE
  * MOVE 時にオフライン
  * 完了まで DML を受け付けない
* セグメントの縮小
  * セグメント内の空き領域をまとめて解放
  * 圧縮時は DML を受付可能
  * ただし HWM の変更にはディクショナリロックが必要
  * オンライン重視の場合は圧縮のみの `COMPACT` 句を使用
* オンライン再定義
  * 変更後の定義で仮表作成
  * `DBMS_REDEFINITION` パッケージを使用して再定義
  * 元表と仮表の2倍の領域が必要だが DML を受け付ける

# 表圧縮(7-6)

圧縮したい場合の定義方法

```sql
CREATE TABLE tablename(col1 number)
ROW STORE COMPRESS ADVANCED
```

* 基本表圧縮
  * `ROW STORE COMPRESS BASIC` 句で設定
  * ダイレクトロードのみ圧縮
    * SQL*Loader のダイレクトパス
    * `CREATE TABLE AS SELECT`
    * パラレルダイレクトインサート
    * APPEND ヒント付き `INSERT INTO SELECT`
  * ブロック内の連続した空き領域の最大化
  * デフォルトの PCTFREE 属性が 0 になる
* 拡張行圧縮
  * `ROW STORE COMPRESS ADVANCED` 句で設定
  * ダイレクトロード時と通常の DML の両方で圧縮
  * 行、列の重複値をブロック先頭のシンボル表へのポインタに置換
  * 非圧縮に必要な情報をブロック内に格納
* ハイブリッド列圧縮
  * `COMPRESS FOR QUERY` 句、`COMPRESS FOR ARCHIVE` 句
  * Exadata、Pillar Axion、Sun ZFS Storage Appliace(ZFSSA) ストレージで利用できる
  * 行のグループを列形式で格納するため、指定列をまとめて圧縮ユニットに格納

MERGE = UPDATE + INSERT

# 遅延セグメント作成(7-8)

Oracle DB 11.2.0.1 はパーティション表、パーティション索引にも遅延セグメント作成を適用できない

# 索引構成表(7-8)

# 自動セグメントアドバイザ(7-11)

* 対象表領域について AWR スナップショットからサンプリングされた分析データを抽出
* デフォルトは 1日1回
* **対象となる表領域やセグメントは指定できない**
* 分析が完了しなかったら次回続きを行う

# RESUMABLE (7-12)

* `ALTER SESSION ENABLE RESUMABLE` は `RESUMABLE` 権限のみあれば実行できる

# UNDO_RETENTION(8-1)

* `UNDO_RETENTION` は秒
* UNDO 表領域に `RETENTION_GUARANTEE` が設定されていた場合は、`UNDO_RETENTION` による保存期間中に上書きしようとしているトランザクション側をエラーにして保護を強制できる

# 統合監査が有効な場合(10-2)

* 従来の監査証跡に **記録しない**
* 統合監査証跡は AUDSYS スキーマにのみ保存される
* 設定は以下 2 step
  * `CREATE AUDIT POLICY`
  * `AUDIT POLICY`

ただし以下は **(統合監査の有効無効に限らず)常に監査される**

* DB **起動前** の特権ユーザーによるトップレベル文
  * 特権ユーザー: SYSDBA, SYSOPER など
  * トップレベル文: 接続や STARTUP/SHUTDOWN など
  * 非統合監査モードでも監査される
* 監査ポリシー管理
  * `CREATE/ALTER/DROP AUDIT POLICY`、`AUDIT` や `NO AUDIT`
* FGA 管理
  * `DBMS_FGA` パッケージの使用
* 監査証跡管理
  * `DBMS_AUDIT_MGMT` パッケージ、`AUDSYS` スキーマの表への `ALTER TABLE`
* RMAN による処理
  * Backup、Restore、Recover 文

# アプリケーションコンテキスト(10-3)

# キュー書き込みモード(10-4)

# 12cの統合監査(10-6)
oracle ホーム毎に有効化、明示していないばあい　は混合モード

# DBCA から設定できること

* Oracle Database Vault の有効化
* Enterprise Manager Cloud Control への登録
* Label Security の登録と有効化

以下はできない

* 推奨のバックアップの有効化

# Oracle Restart

* スタンドアロン・サーバー用の Oracle Grid Infrastructure
  * Oracle Restart
    * 監視対象のコンポーネント
      * データベースインスタンス
      * Oracle ASM インスタンス
      * Oracle ASM ディスクグループ
      * Oracle Notification Services(ONS)
    * ※ 作成方法によっては監視対象に自動で追加されない
  * Oracle ASM
* コンポーネントの追加、削除、起動停止、変更、有効化、無効化を行う場合
  * `srvctl add` など

## srvctl と crsctl の用途の違い

* srvctl
  * Oracle から提供されるリソースの管理
    * リスナー
    * インスタンス
    * ディスクグループ
    * ネットワーク
* crsctl
  * Oracle Clusterware およびそのリソースの管理

# Oracle Restart の制御

* Oracle Restart は OS の init デーモンによって起動
* Oracle Clusterware Control(CRSCTL) ユーティリティを使用して、Oracle Restart の状態を制御できる
  * `$ crsctl config has` : Oracle Restart の構成を表示
  * `$ crsctl {enable | disable} has` : Oracle Restart の自動再起動の有効化・無効化
  * `$ crsctl {start | stop} has` : Oracle Restart の起動・停止
* CRSCTL ユーティリティを使用して Oracle Restart を停止すると Oracle Restart 管理下のコンポーネントも停止される

# アップグレードと移行で押さえること

* それぞれの特徴、基本的な手順
  * DBUA
  * 手動(STARTUP UPGRADE)
  * Expdp / Impdp
* ツール
  * preupgrd.sql: アップグレード前情報ツール
  * catctl.pl: ・アップグレード・ユーティリティ

Oracle Database アップグレードガイド 12c リリース

# アップグレード前のパフォーマンス・テスト

* データベース・リプレイ
  * 本番 DB 上でのワークロードをキャプチャーし、テスト環境上でリプレイしてパフォーマンスをテストできる
  * テスト環境でのリプレイ後、リプレイ前の状態にデータを復元する
* SQL パフォーマンス・アナライザ
  * 用意した SQL チューニング・セットについて、リリースやパラメータ設定などを変更した場合にどのような影響が出るかテストすることができる



# リスナー登録プロセス(LREG)

* データベースインスタンスおよびディスパッチャプロセスに関する情報を Oracle Net Listener に登録
* LREG からリスナーに以下の情報が提供される
  * データベースサービス名
  * サービスに関連づけられたインスタンス名とその現在の負荷および最大負荷
  * サービス・ハンドラ(ディスパッチャおよび専用サーバー)のタイプ、プロトコル・アドレス、その現在の負荷および最大負荷
* リスナー起動後に LREG により動的登録されるまで最大 60秒かかる
* `ALTER SYSTEM REGISTER` コマンドにより手動で登録

# ユーザーの認証方式

* パスワード・ファイルはインスタンスを起動する特権ユーザーの認証に使用する
  * それ以外のユーザーのパスワードは含まない

# Oracle LInux 6 および Oracle RDBMS Pre-Install resource_parameters

* Oracle Grid Infrastructure および Oracle Database のインストールに必要な追加パッケージを自動的にインストール
* OS の構成
  * カーネル・パラメータの設定
  * 以下の OS ユーザー、グループの構成
    * oracle : Oracle Database インストール所有者
    * oinstall : Oracle インベントリ・グループ
    * dba : Oracle 管理権限

# サイレントモードによるインストール・構成

* 提供されるテンプレートを元にレスポンス・ファイルを用意することで、サイレント・モード(非対話型)でインストール・構成を行うことができる。
* `./runinstaller -silent -responsefile <filename>`
* Oracle Universal Installer を対話型モードで実行し、「サマリー」ページで「レスポンスファイルの保存」を行うことも可能
* ASMCA、DBCA、NetCA もサイレントモードで実行可能

# データリカバリ・アドバイザで診断できる障害

* アクセスできないデータファイルや制御ファイルなどのコンポーネント
  * 存在しない、適切なアクセス権限がない、オフラインになっているなど
* ブロック・チェックサム障害、無効なブロック・ヘッダー・フィールド値などの物理的な破損
* 他のデータベース・ファイルより古いデータファイルなどの矛盾
* ハードウェア・エラー、OSのドライバの障害、OSのリソース制限(ex. オープンしているファイル数)の超過などの I/O 障害

# Database Smart Flash Cache

SSD を2次キャッシュとして利用する方法

## 適用を検討するケース

* DB が Solaris または Oracle Linux OS であること
* AWR レポートまたは STATSPACK レポートのバッファ・プール・アドバイザセクションに以下のことが書かれてる
  * バッファキャッシュのサイズを2倍にすると効果的
* `db file sequential read` が上位待機イベント
* 手元に呼びの CPU がある

## 初期化パラメータ

* `DB_FLASH_CACHE_FILE`
* `DB_FLASH_CACHE_SIZE`

# フラッシュバック機能について

機能を使用するには以下の構成タスクを実行する必要がある。

* 自動 UNDO 管理
  * 自動 UNDO 管理(AUM) を有効化する
    * `UNDO_MANAGEMENT`
    * `UNDO_TABLESPACE`
    * `UNDO_RETENTION`
* Flashback Transaction Query に関する DB 構成
  * ユーザーまたは管理者が以下を実行
    * DB が 10.0 と互換性があることを確認
    * サプリメンタル・ロギングを有効にする
      * `ALTER DATABASE ADD SUPPLEMENTAL LOG DATA`
* フラッシュバック・トランザクションに関するデータベースの構成
  * DB が MOUNT されているが、 OPEN していない状態で ARCHIVELOG を有効化
    * `ALTER DATABASE ARCHIVELOG;`
  * 1 つ以上のアーカイブログを開く
    * `ALTER SYSTEM ARCHIVE LOG CURRENT;`
  * 必要最低限の主キーのサプリメンタル・ロギングが有効になっていない場合、有効化する
    * `ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;`
    * `ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;`
  * 外部キーの依存性を追跡する場合は、外部キーのサプリメンタルロギングを有効化する
    * `ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (FOREIGN KEY) COLUMNS;`
* 特定の LOB 列に対する Oracle Flashback 操作の有効化
  * `ALTER TABLE` 文を `RETENTION` オプションとともに使用する
* 必要な権限の付与


# SQL 実行計画管理

## SPM 展開アドバイザの自動タスクの構成方法

* SQL*Plus を使って適切な権限で DBに接続して現在のタスク設定を問い合わせる
  ```sql
  COL PARAMETER_NAME FORMAT a25
  COL VALUE FORMAT a10
  SELECT PARAMETER_NAME, PARAMETER_VALUE AS "VALUE"
  FROM   DBA_ADVISOR_PARAMETERS
  WHERE
    TASK_NAME = 'SYS_AUTO_SPM_EVOLVE_TASK'
    AND (
      PARAMETER_NAME = 'ACCEPT_PLANS'
      OR PARAMETER_NAME = 'TIME_LIMIT'
    )
  ;
  ```

  * 次のプロシージャでパラメータを設定する
    ```sql
    BEGIN
      DBMS_SPM.SET_EVOLVE_TASK_PARAMETER(
        task_name => 'SYS_AUTO_SPM_EVOLVE_TASK'
        , parameter => parameter_name  # ex. LOCAL_TIME_LIMIT, ACCEPT_PLANS
        , value     => value
      );
    END;
    /
    ```

## SPM の手動展開

* 展開タスクを作成します。
  * `DBMS_SPM.CREATE_EVOLVE_TASK`
* オプションで、展開タスクのパラメータを設定します。
  * `DBMS_SPM.SET_EVOLVE_TASK_PARAMETER`
* 展開タスクを実行します。
  * `DBMS_SPM.EXECUTE_EVOLVE_TASK`
* タスク内の推奨事項を実装します。
  * `DBMS_SPM.IMPLEMENT_EVOLVE_TASK`
* タスクの結果をレポートします。
  * `DBMS_SPM.REPORT_EVOLVE_TASK`

# 拡張統計収集方法

* 列グループの使用状況などをさらに取得してオプティマイザの精度を上げる。
* 列間の相関まで見る

具体的に実行する方法は以下の通り。

* `DBMS_STATS.SEED_COL_USAGE(<sqlset_name>, <sqlset_owner_name>, <seconds>)`
* 対象の表に対して必要なクエリを実行
* `SELECT DBMS_STATS.REPORT_COL_USAGE(<owner>, <table_name>) FROM dual` を実行してレポートを生成
* `SELECT DBMS_STATS.CREATE_EXTENDED_STATS(<owner>, <table_name>)` を実行して拡張統計を実行

# スキーマオブジェクトについて

プロファイルやロールなどの一部のデータベースオブジェクトはスキーマに属さない

以下はスキーマオブジェクト

* 表、索引、パーティション、ビュー、順序、ディメンション、シノニム
* PL/SQL サブプログラムと PL/SQL パッケージ

# 共通ユーザー

* cdb と pdb に共通するユーザー
* `C##` で始まるユーザー名
* CDB$ROOT に接続した状態じゃないと作成できない
* CDB$ROOT ではローカルユーザーは作成できない
* 共通ユーザーで各 PDB に接続するには、事前に各 PDB で CREATE SESSION 権限を付与しておく必要があるo
* 共通ユーザーを削除する際は CONTAINER=ALL を指定する。しないとエラー

# SQL*Loader エクスプレス

* SQL*Loader 制御ファイルを作成する必要がない
* ロードされる表と同じ名前で .dat がついたファイルを検索する(大文字小文字も一致)
