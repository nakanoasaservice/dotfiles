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

## Homebrewのインストール

`flake.nix` の `homebrew` 設定（caskの管理）は、nix-darwinがHomebrew自体をインストールしてくれるわけではなく、既存のHomebrewを操作するだけです。まだ入っていない場合は先に[公式サイト](https://brew.sh/)の手順でインストールしてください。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

表示に従って進める（`sudo` が求められることがあります）。完了後、次で確認します。

```bash
brew --version
```

## 前提

- Nix が入っていること（flakes 有効。`flake.nix` で `nix-command flakes` を要求）
- Homebrew が入っていること（`flake.nix` の `homebrew.casks` を適用するため）
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

## SSH鍵・Git署名鍵をGitHubに登録（初回のみ）

`programs.nix-secure-enclave-key` により、Secure Enclave（Touch ID チップ）で保護されたSSH鍵をGit署名・GitHubへのpush両方に使っています。鍵自体は `darwin-rebuild switch` 時に自動生成されますが、**GitHubへの登録は書き込み操作のため自動化しておらず、初回セットアップ時に手動で実行する必要があります**。

```bash
# 1. darwin-rebuild switch 適用後、鍵が作られたか確認
nix-secure-enclave-key doctor
nix-secure-enclave-key pub

# 2. gh に鍵管理スコープを付与（このスコープが無いと登録APIが呼べない）
gh auth refresh --hostname github.com --scopes admin:ssh_signing_key,admin:public_key

# 3. GitHubに登録（認証用・署名用の両方を一度に登録）
nix-secure-enclave-key github add --type both

# 4. 動作確認
ssh -T git@github.com
git commit --allow-empty -m "test signed commit" && git log --show-signature -1
```

- `nix-secure-enclave-key` は macOS の CryptoTokenKit / Secure Enclave を直接使うため、秘密鍵の実体はチップの外に一度も出ません。`~/.ssh/id_enclave_key` は鍵そのものではなく、どのSecure Enclave identityを使うかを示す非秘密の参照ファイルです（削除すると設定が壊れるので消さないこと）。
- 以前使っていた [Secretive](https://github.com/maxgoedjen/secretive) は動作確認後に廃止し、この鍵に一本化しています。
- 詳細: [ryoppippi/nix-secure-enclave-key](https://github.com/ryoppippi/nix-secure-enclave-key)

## flake の入力を更新

`nixpkgs` や `nix-darwin` など、`flake.nix` の `inputs` をロックファイルに沿って最新へ寄せたいときは、リポジトリのルートで次を実行します。

```bash
nix flake update
```

`flake.lock` が更新されます。内容を確認して問題なければコミットし、そのあと上記の `darwin-rebuild switch` でシステムに反映します。

## 補足

- 変更履歴の確認: `darwin-rebuild changelog`
- 設定の中身は `flake.nix` と同梱の home-manager モジュールを参照
