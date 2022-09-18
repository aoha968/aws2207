require 'spec_helper'

listen_port = 80

# -------------------------------------------------------------------------#
# インストール関連
# -------------------------------------------------------------------------#
# nginx package & version check
describe package('nginx') do
  it { should be_installed }
  it { should be_installed.with_version "1.20.0" }
end

# git package
describe package('git') do
  it { should be_installed }
  it { should be_installed.with_version "2.37.1" }
end

# bundle package
describe package('bundler') do
  it { should be_installed.by('gem').with_version('2.3.14') }
end

# ruby version
describe command('ruby -v') do
  its(:stdout) { should match /ruby 2\.7\.0/ }
end

# rails version
describe command('rails --version') do
  its(:stdout) { should match /Rails 6\.1\.3\.1/ }
end

# -------------------------------------------------------------------------#
# ファイルの存在確認
# -------------------------------------------------------------------------#
# unicornの設定ファイルがあるか
describe file('/var/www/raisetech-live8-sample-app/config/unicorn.conf.rb') do
  it { should be_file }
end

# -------------------------------------------------------------------------#
# ファイルの読み込み権限
# -------------------------------------------------------------------------#
%w{
  /var/www/raisetech-live8-sample-app/log/nginx.access.log
  /var/www/raisetech-live8-sample-app/log/nginx.error.log
  /var/www/raisetech-live8-sample-app/log/unicorn.log
}.each do |logfile|
  describe file(logfile) do
    it { should be_readable.by_user('ec2-user') }
  end
end

# -------------------------------------------------------------------------#
# サービスの起動確認
# -------------------------------------------------------------------------#
# nginx service status
describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

# port check
describe port(listen_port) do
  it { should be_listening }
end

# HTTP Status Code (curlでHTTPアクセスしてレスポンス確認)
describe command('curl http://127.0.0.1:#{listen_port}/_plugin/head/ -o /dev/null -w "%{http_code}\n" -s') do
  its(:stdout) { should match /^200$/ }
end

# unicornの起動確認
describe command('ps -ef | grep unicorn | grep -v grep') do
  let(:disable_sudo) { true }
  its(:exit_status){ should eq 0 }
end

# -------------------------------------------------------------------------#
# ユーザーとグループ
# -------------------------------------------------------------------------#
# グループが存在するか確認する
describe group('ec2-user') do
  it { should exist }
end

# ユーザが指定のグループに所属しているか確認する
describe user('ec2-user') do
  it { should belong_to_group 'ec2-user' }
end