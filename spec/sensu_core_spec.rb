require File.dirname(__FILE__) + '/../lib/sensu-cli/sensu.rb'
require File.dirname(__FILE__) + '/helpers.rb'
require 'json'

describe 'SensuCli::Core' do
  include Helpers

  before do
    @core = SensuCli::Core.new
  end

  it 'can return proper all clients paths' do
    cli = {
      :command => 'clients',
      :method => 'Get',
      :fields => {}
    }
    @core.api_path(cli).should == {:path=>"/clients", :method=>"Get", :command=>"clients", :payload=>false}
  end

  it 'can return proper client path' do
    cli = {
      :command => 'clients',
      :method => 'Get',
      :fields => {:name => "test"}
    }
    @core.api_path(cli).should == {:path=>"/clients/test", :method=>"Get", :command=>"clients", :payload=>false}
  end

  it 'can return proper client history path' do
    cli = {
      :command => 'clients',
      :method => 'Get',
      :fields => {:name => "test", :history => true}
    }
    @core.api_path(cli).should == {:path=>"/clients/test/history", :method=>"Get", :command=>"clients", :payload=>false}
  end

  it 'can return proper info path' do
    cli = {
      :command => 'info',
      :method => 'Get',
      :fields => {}
    }
    @core.api_path(cli).should == {:path=>"/info", :method=>"Get", :command=>"info", :payload=>false}
  end

  it 'can return proper health path' do
    cli = {
      :command => 'health',
      :method => 'Get',
      :fields => {}
    }
    @core.api_path(cli).should == {:path=>"/health", :method=>"Get", :command=>"health", :payload=>false}
  end

  it 'can return proper all stashes path' do
    cli = {
      :command => 'stashes',
      :method => 'Get',
      :fields => {}
    }
    @core.api_path(cli).should == {:path=>"/stashes", :method=>"Get", :command=>"stashes", :payload=>false}
  end

  it 'can return proper single stash path' do
    cli = {
      :command => 'stashes',
      :method => 'Get',
      :fields => {:path => 'silence'}
    }
    @core.api_path(cli).should == {:path=>"/stashes/silence", :method=>"Get", :command=>"stashes", :payload=>false}
  end

  it 'can return proper all checks path' do
    cli = {
      :command => 'checks',
      :method => 'Get',
      :fields => {}
    }
    @core.api_path(cli).should == {:path=>"/checks", :method=>"Get", :command=>"checks", :payload=>false}
  end

  it 'can return proper single checks path' do
    cli = {
      :command => 'checks',
      :method => 'Get',
      :fields => {:name => 'test'}
    }
    @core.api_path(cli).should == {:path=>"/check/test", :method=>"Get", :command=>"checks", :payload=>false}
  end

  it 'can return all events path' do
    cli = {
      :command => 'events',
      :method => 'Get',
      :fields => {}
    }
    @core.api_path(cli).should == {:path=>"/events", :method=>"Get", :command=>"events", :payload=>false}
  end

  it 'can return all events for a client path' do
    cli = {
      :command => 'events',
      :method => 'Get',
      :fields => {:client => 'test'}
    }
    @core.api_path(cli).should == {:path=>"/events/test", :method=>"Get", :command=>"events", :payload=>false}
  end

  it 'can return all specific event for a client path' do
    cli = {
      :command => 'events',
      :method => 'Get',
      :fields => {:client => 'test', :check => 'check'}
    }
    @core.api_path(cli).should == {:path=>"/events/test/check", :method=>"Get", :command=>"events", :payload=>false}
  end

  it 'can return all proper client resolve path' do
    cli = {
      :command => 'resolve',
      :method => 'Post',
      :fields => {:client => "test"}
    }
    payload = {:client => "test", :check => nil}.to_json
    @core.api_path(cli).should == {:path=>"/event/resolve", :method=>"Post", :command=>"resolve", :payload=>payload}
  end

  it 'can return all proper client/check resolve path' do
    cli = {
      :command => 'resolve',
      :method => 'Post',
      :fields => {:client => "test", :check => 'check'}
    }
    payload = {:client => "test", :check => 'check'}.to_json
    @core.api_path(cli).should == {:path=>"/event/resolve", :method=>"Post", :command=>"resolve", :payload=>payload}
  end

  it 'can return all aggregates path' do
    cli = {
      :command => 'aggregates',
      :method => 'Get',
      :fields => {}
    }
    @core.api_path(cli).should == {:path=>"/aggregates", :method=>"Get", :command=>"aggregates", :payload=>false}
  end

  it 'can return aggregates check path' do
    cli = {
      :command => 'aggregates',
      :method => 'Get',
      :fields => {:check => 'check'}
    }
    @core.api_path(cli).should == {:path=>"/aggregates/check", :method=>"Get", :command=>"aggregates", :payload=>false}
  end

  it 'can return silence client path' do
    cli = {
      :command => 'silence',
      :method => 'Post',
      :fields => {:client => 'client'}
    }
    payload = {:timestamp => Time.now.to_i}.to_json
    @core.api_path(cli).should == {:path=>"/stashes/silence/client", :method=>"Post", :command=>"silence", :payload=>payload}
  end

  it 'can return silence client/check path' do
    cli = {
      :command => 'silence',
      :method => 'Post',
      :fields => {:client => 'client', :check => 'check'}
    }
    payload = {:timestamp => Time.now.to_i}.to_json
    @core.api_path(cli).should == {:path=>"/stashes/silence/client/check", :method=>"Post", :command=>"silence", :payload=>payload}
  end

  it 'can setup settings' do
    @core.settings
    SensuCli::Config.host.should match(/^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/)
    SensuCli::Config.port.should eq('4567')
    SensuCli::Config.ssl.should satisfy { true || false}
  end

  it 'can pretty empty response' do
    res = []
    output = capture_stdout { @core.pretty(res) }
    output.should == "\e[36mno values for this request\e[0m\n"
  end

  it 'can pretty a hash' do
    res = [{:test => "value"}]
    output = capture_stdout { @core.pretty(res) }
    output.should == "\e[33m-------\e[0m\n\e[36mtest:  \e[0m\e[32mvalue\e[0m\n"
  end

  it 'can pretty an array' do
    res = ["test","test1"]
    output = capture_stdout { @core.pretty(res) }
    output.should == "\e[33m-------\e[0m\n\e[36mtest\e[0m\n\e[33m-------\e[0m\n\e[36mtest1\e[0m\n"
  end

  it 'can pretty a hash inside an array' do
    res = [{:test => "value",:test1 => "value1"}]
    output = capture_stdout { @core.pretty(res) }
    output.should == "\e[33m-------\e[0m\n\e[36mtest:  \e[0m\e[32mvalue\e[0m\n\e[36mtest1:  \e[0m\e[32mvalue1\e[0m\n"
  end

end
