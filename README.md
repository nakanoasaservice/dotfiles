# dotfiles

このリポジトリは **nix-darwin** と **home-manager** で macOS の環境を宣言的に管理するための設定です。

## Nix（Lix）のインストール

まだ Nix が入っていない場合は、[Lix インストーラー](https://git.lix.systems/lix-project/lix-installer)で入れるのが手軽です。このリポジトリは Lix でも従来の Nix でも同じように使えます。

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

表示に従って進める（`sudo` が求められることがあります）。完了後、次で Lix が使えていることを確認します。

```bash
nix --version
```

出力に `Lix` と出ていれば問題ありません。

既に Nix や Lix が入っているマシンでは、上書きインストールではなくアップグレードになることがあります。詳しくは [Installing Lix](https://lix.systems/install/) の「Existing Installs」を参照してください。

## 前提

- Nix が入っていること（flakes 有効。`flake.nix` で `nix-command flakes` を要求）
- このリポジトリをチェックアウトしたディレクトリに `cd` してからコマンドを実行すること

## 適用（この Mac に反映）

**初回**（まだ `darwin-rebuild` が PATH にないとき）:

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#nakano-mbp
```

**2 回目以降**（nix-darwin 適用済みで `darwin-rebuild` が使えるとき）:

```bash
sudo darwin-rebuild switch --flake .#nakano-mbp
```

`nakano-mbp` は `flake.nix` のホスト名（darwinSystem の名前）に合わせています。設定を変えたらいつでも上記で再適用できます。

## flake の入力を更新

`nixpkgs` や `nix-darwin` など、`flake.nix` の `inputs` をロックファイルに沿って最新へ寄せたいときは、リポジトリのルートで次を実行します。

```bash
nix flake update
```

`flake.lock` が更新されます。内容を確認して問題なければコミットし、そのあと上記の `darwin-rebuild switch` でシステムに反映します。

## 補足

- 変更履歴の確認: `darwin-rebuild changelog`
- 設定の中身は `flake.nix` と同梱の home-manager モジュールを参照
