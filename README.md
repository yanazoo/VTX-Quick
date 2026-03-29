# VTX Quick

EdgeTX + ELRS 環境で VTX チャンネルをスイッチ一発で切り替える Lua スクリプト集。

---

## ファイル構成

| ファイル | 配置場所 | 用途 |
|----------|----------|------|
| `VTXQuick.lua` | `/SCRIPTS/TOOLS/` | タッチ UI ツール（Tools メニュー）バンド・チャンネル・出力をまとめて変更 |
| `VTX_R2.lua` | `/SCRIPTS/FUNCTIONS/` | スイッチ割り当て用　Race 2ch　5695 MHz |
| `VTX_R3.lua` | `/SCRIPTS/FUNCTIONS/` | スイッチ割り当て用　Race 3ch　5732 MHz |
| `VTX_R4.lua` | `/SCRIPTS/FUNCTIONS/` | スイッチ割り当て用　Race 4ch　5769 MHz |
| `VTX_R5.lua` | `/SCRIPTS/FUNCTIONS/` | スイッチ割り当て用　Race 5ch　5806 MHz |
| `VTX_E1.lua` | `/SCRIPTS/FUNCTIONS/` | スイッチ割り当て用　Europ 1ch　5705 MHz |
| `VTX_F1.lua` | `/SCRIPTS/FUNCTIONS/` | スイッチ割り当て用　FatShark 1ch　5740 MHz |
| `VTX_F4.lua` | `/SCRIPTS/FUNCTIONS/` | スイッチ割り当て用　FatShark 4ch　5800 MHz |

---

## インストール

SD カードの以下のパスにコピーしてください。

```
/SCRIPTS/TOOLS/VTXQuick.lua
/SCRIPTS/FUNCTIONS/VTX_R2.lua
/SCRIPTS/FUNCTIONS/VTX_R3.lua
/SCRIPTS/FUNCTIONS/VTX_R4.lua
/SCRIPTS/FUNCTIONS/VTX_R5.lua
/SCRIPTS/FUNCTIONS/VTX_E1.lua
/SCRIPTS/FUNCTIONS/VTX_F1.lua
/SCRIPTS/FUNCTIONS/VTX_F4.lua
```

---

## TX15MAX 設定方法

### スイッチスクリプト（VTX_Rxx / VTX_Exx / VTX_Fxx）

1. **MDL → スペシャルファンクション** を開く
2. 使用したいスロットに以下を設定する

| 項目 | 設定値 |
|------|--------|
| スイッチ | 使用するスイッチ・方向を選択 |
| スクリプト | 対応する VTX_Xxx を選択 |
| **実行モード** | **`1x`** |

> **実行モードは必ず `1x` を選択してください。**
> スイッチの立ち上がりエッジで 1 回だけ `run()` が呼ばれ、
> その後の書き込み完走・次回プッシュの準備は `background()` が自動で行います。

#### 設定例

| スロット | スイッチ | スクリプト | チャンネル |
|----------|----------|-----------|------------|
| SF1 | SA↓ | VTX_R2 | Race 2　5695 MHz |
| SF2 | SA↑ | VTX_R3 | Race 3　5732 MHz |
| SF3 | SB↓ | VTX_R4 | Race 4　5769 MHz |
| SF4 | SB↑ | VTX_R5 | Race 5　5806 MHz |

### タッチ UI ツール（VTXQuick）

1. **Tools メニュー** から `VTXQuick` を起動
2. タッチでバンド・チャンネル・出力を自由に変更

---

## 動作の仕組み

### スイッチスクリプトの動作フロー

```
プロポ起動
  └─ init()：ELRS モジュールへ PING 送信、フィールド列挙を開始

スイッチ未操作（毎フレーム background() が動く）
  ├─ 列挙中（PI/EN）    → 応答を受け取りフィールド情報を収集
  ├─ 列挙完了（RY）     → スイッチ操作待ち
  ├─ 書き込み中（WB〜CF）→ 書き込みシーケンスを完走させる
  └─ 書き込み完了（DN） → 再列挙を開始し次回プッシュに備える

スイッチ操作（1x で run() が 1 回だけ呼ばれる）
  ├─ 列挙完了済み（RY） → 即バンド・チャンネル書き込み開始
  └─ まだ列挙中         → trigger フラグをセット
                            列挙完了次第 background() が自動で書き込み開始
```

---

## 動作環境

- EdgeTX 2.11 以上
- ELRS TX モジュール（CRSF 接続）
- RadioMaster TX15 MAX（他の EdgeTX 対応機でも動作可）
