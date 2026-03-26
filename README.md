# VTX Quick

EdgeTX + ELRS 環境で VTX チャンネルをスイッチ一発で切り替える Lua スクリプト集。
One-tap VTX channel switching scripts for EdgeTX + ELRS.

---

## ファイル構成 / Files

| File | 用途 |
|------|------|
| `VTXQuick.lua` | タッチUIツール（Tools メニュー）全チャンネル・出力変更 |
| `VTX_R2.lua` | スイッチ割り当て用 R2 5695 MHz |
| `VTX_R3.lua` | スイッチ割り当て用 R3 5732 MHz |
| `VTX_R4.lua` | スイッチ割り当て用 R4 5769 MHz |
| `VTX_R5.lua` | スイッチ割り当て用 R5 5806 MHz |
| `VTX_E1.lua` | スイッチ割り当て用 E1 5705 MHz |
| `VTX_F1.lua` | スイッチ割り当て用 F1 5740 MHz |
| `VTX_F4.lua` | スイッチ割り当て用 F4 5800 MHz |

---

## インストール / Installation

SDカードの以下のパスに配置してください。
Copy files to your SD card:

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

## TX15MAX 設定方法 / TX15MAX Radio Setup

### スイッチスクリプト / Switch Scripts

1. TX15MAX の **MDL → スペシャルファンクション** を開く
2. 空きスロットに以下を設定（**実行モードは「An」を選択**）

| スロット | スイッチ | スクリプト | チャンネル |
|----------|----------|-----------|------------|
| SF1 | SW1↓ | VTX_R2 | R2 5695 MHz |
| SF2 | SW2↓ | VTX_R3 | R3 5732 MHz |
| SF3 | SW3↓ | VTX_R4 | R4 5769 MHz |
| SF4 | SW4↓ | VTX_R5 | R5 5806 MHz |
| SF5 | SW5↓ | VTX_E1 | E1 5705 MHz |
| SF6 | SW6↓ | VTX_F1 | F1 5740 MHz |
| SF7 | SW6↑ | VTX_F4 | F4 5800 MHz |

> **実行モード「An」（continuous）を選択してください。**
> スイッチが ON の間ずっと `run()` が呼ばれますが、内部フラグで1サイクルのみ実行されます。
> 「An」にすることで、**プロポ起動時にスイッチが既にON位置にある場合も自動でチャンネルが設定されます。**
>
> **Set the execution mode to "An" (continuous).**
> `run()` is called every frame while the switch is ON, but an internal flag ensures only one cycle executes per activation.
> With "An" mode, **the VTX channel is also set automatically at radio startup if the switch is already in the ON position.**

### タッチUIツール / Touch UI Tool

1. **Tools メニュー** から `VTXQuick` を起動
2. タッチで任意のチャンネル・出力を変更

Open `VTXQuick` from the **Tools menu** to change any channel or power level via touch UI.

---

## 設計 / Design

- スイッチの ON/OFF 検知は **EdgeTX（スペシャルファンクション）側に委譲**
- 各スクリプトは「接続 → チャンネル送信 → 完了」のみ実行（99行・ミニマル実装）
- 監視ループ・設定ファイル・ログなし

Switch ON/OFF detection is fully delegated to EdgeTX Special Functions.
Each script performs only: connect → send channel → done (99 lines, minimal).
No monitoring loop, no config file, no logging.

---

## 動作環境 / Requirements

- EdgeTX 2.11+
- ELRS TX モジュール（CRSF 接続）
- RadioMaster TX15 MAX（他の EdgeTX 対応機でも動作可）
