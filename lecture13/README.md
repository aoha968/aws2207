# CircleCI/Ansible を使用した DevOps

CircleCI、ServerSpec、Ansible を併用してインフラ環境を構築する。
本 Lecture の目的は以下

- Ansible に慣れること

  - 構文チェック
  - Playbook
  - Dry Run

- CircleCI

  - パイプライン処理による自動化

- ServerSpec

  -　構成設定の自動テスト

上記だけだと動作させるアプリケーションがないため、配布されている Rails アプリケーションも合わせて構築するようにする。

## 使用環境/ツール

- AWS
- Terraform
- CircleCI
- ServerSpec
- Ansible

## 構築するインフラ構成図

![AWS第13回課題 drawio](https://user-images.githubusercontent.com/92103678/197784342-8b27078a-63b0-4950-80a9-32c7ed84860d.png)

## DevOps したコード

https://github.com/aoha968/DevOps_RailsApplication
