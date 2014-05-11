require File.dirname(__FILE__) + '/../lib/sensu-cli.rb'
require File.dirname(__FILE__) + '/../lib/sensu-cli/settings.rb'

describe 'SensuCli::Settings' do

  before do
    @settings = SensuCli::Settings.new
    @file = File.join(File.dirname(__FILE__), 'settings/settings.rb')
  end

  it 'can check if a file exists' do
    @settings.file?(@file).should be_true
  end

  it 'can create a configuration file' do
    require 'rainbow'
    directory = '/tmp/sensu'
    file = 'temp.rb'
    full_path = File.join(directory, file)
    File.exist?(full_path).should be_false
    -> { @settings.create(directory, full_path) }.should raise_error SystemExit
    File.exist?(full_path).should be_true
    File.delete(full_path)
  end

  it 'can return a configuration value' do
    SensuCli::Config.from_file(@file)
    SensuCli::Config.host.should eq('127.0.0.1')
    SensuCli::Config.port.should eq('4567')
    SensuCli::Config.ssl.should eq(false)
    SensuCli::Config.user.should eq('some_user')
    SensuCli::Config.password.should eq('some_secret_password')
  end

end
