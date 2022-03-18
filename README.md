# Alter Linux Repository

<p>
    <a href="/LICENSE.md">
        <img src="https://img.shields.io/badge/license-MIT--SUSHI-orange?style=flat-square">
    </a>
    <a href="https://github.com/FascodeNet/alterlinux-repo/stargazers">
        <img src="https://img.shields.io/github/stars/FascodeNet/alterlinux-repo?color=yellow&style=flat-square&logo=github">
    </a>
    <a href="https://github.com/FascodeNet/alterlinux-repo/commits/">
        <img src="https://img.shields.io/github/last-commit/FascodeNet/alterlinux-repo?style=flat-square">
    </a>
    <a href="https://github.com/FascodeNet/alterlinux-repo/">
        <img src="https://img.shields.io/github/repo-size/FascodeNet/alterlinux-repo?style=flat-square">
    </a>
    <a href="https://github.com/FascodeNet/alterlinux-repo">
        <img src="https://img.shields.io/tokei/lines/github/FascodeNet/alterlinux-repo?style=flat-square">
    </a>
</p>

このGit RepositoryはPKGBUILDとビルドスクリプトで構成されています。

`alter-stable`リポジトリはAlter Linuxの動作やAlterISOの実行に必要な最小限のパッケージが含まれています。

このリポジトリのBashスクリプトは Arch Linux x86_64上で動作します。

## Document

### リポジトリについて

AURにアップロードすることのできない、もしくは頻繁に使用するパッケージを置いているリポジトリです。現在、GitHub PagesとOSDNでホストされています。

### スクリプトについて

#### `start.sh`

Docker上でビルドを行います

### `scruots/main.sh`

Chroot環境上でのパッケージのビルドを行います。

このスクリプトはArch Linux上でのみ動作します。

### `scripts/rsync.sh`


### Contribute



## Todo
- [ ] Arch Linux上でのリポジトリのビルド
  - [x] x86_64
  - [x] i686
  - [ ] pentium4
  - [ ] ARMv8
- [ ] Arch Linux上でのデプロイ
 - [x] Rsyncを使った追加のデプロイ
 - [ ] Sftpを使った旧ファイルの削除
- [ ] ドキュメントの整備
- [ ] パッケージの更新
  - [ ] `filesystem`
- [ ] Docker上でのビルドとデプロイ
- [ ] GitHub Actionsを利用した自動ビルド
- [ ] Fascodeサーバを使った自動デプロイ
