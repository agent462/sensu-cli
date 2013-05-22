require File.dirname(__FILE__) + '/../lib/sensu-cli/base.rb'
require File.dirname(__FILE__) + '/helpers.rb'
require 'json'

describe 'SensuCli::Base' do
  include Helpers

  before do
    @core = SensuCli::Base.new
  end

  describe 'handle paths' do

    it 'can return proper all clients paths' do
      cli = {
        :command => 'clients',
        :method => 'Get',
        :fields => {}
      }
      @core.instance_variable_set(:@command, "clients")
      @core.api_path(cli).should == {:path=>"/clients", :method=>"Get", :command=>"clients", :payload=>false}
    end

    it 'can return proper client path' do
      cli = {
        :command => 'clients',
        :method => 'Get',
        :fields => {:name => "test"}
      }
      @core.instance_variable_set(:@command, "clients")
      @core.api_path(cli).should == {:path=>"/clients/test", :method=>"Get", :command=>"clients", :payload=>false}
    end

    it 'can return proper client history path' do
      cli = {
        :command => 'clients',
        :method => 'Get',
        :fields => {:name => "test", :history => true}
      }
      @core.instance_variable_set(:@command, "clients")
      @core.api_path(cli).should == {:path=>"/clients/test/history", :method=>"Get", :command=>"clients", :payload=>false}
    end

    it 'can return proper info path' do
      cli = {
        :command => 'info',
        :method => 'Get',
        :fields => {}
      }
      @core.instance_variable_set(:@command, "info")
      @core.api_path(cli).should == {:path=>"/info", :method=>"Get", :command=>"info", :payload=>false}
    end

    it 'can return proper health path' do
      cli = {
        :command => 'health',
        :method => 'Get',
        :fields => {}
      }
      @core.instance_variable_set(:@command, "health")
      @core.api_path(cli).should == {:path=>"/health?consumers=&messages=", :method=>"Get", :command=>"health", :payload=>false}
    end

    it 'can return proper all stashes path' do
      cli = {
        :command => 'stashes',
        :method => 'Get',
        :fields => {}
      }
      @core.instance_variable_set(:@command, "stashes")
      @core.api_path(cli).should == {:path=>"/stashes", :method=>"Get", :command=>"stashes", :payload=>false}
    end

    it 'can return proper single stash path' do
      cli = {
        :command => 'stashes',
        :method => 'Get',
        :fields => {:path => 'silence'}
      }
      @core.instance_variable_set(:@command, "stashes")
      @core.api_path(cli).should == {:path=>"/stashes/silence", :method=>"Get", :command=>"stashes", :payload=>false}
    end

    it 'can return proper all checks path' do
      cli = {
        :command => 'checks',
        :method => 'Get',
        :fields => {}
      }
      @core.instance_variable_set(:@command, "checks")
      @core.api_path(cli).should == {:path=>"/checks", :method=>"Get", :command=>"checks", :payload=>false}
    end

    it 'can return proper check request path' do
      cli = {
        :command => 'checks',
        :method => 'Post',
        :fields => {:check=>"some_check", :subscribers=> ["all"]}
      }
      @core.instance_variable_set(:@command, "checks")
      @core.api_path(cli).should == {:path=>"/check/request", :method=>"Post", :command=>"checks", :payload=>"{\"check\":\"some_check\",\"subscribers\":[\"all\"]}"}
    end

    it 'can return proper single checks path' do
      cli = {
        :command => 'checks',
        :method => 'Get',
        :fields => {:name => 'test'}
      }
      @core.instance_variable_set(:@command, "checks")
      @core.api_path(cli).should == {:path=>"/check/test", :method=>"Get", :command=>"checks", :payload=>false}
    end

    it 'can return all events path' do
      cli = {
        :command => 'events',
        :method => 'Get',
        :fields => {}
      }
      @core.instance_variable_set(:@command, "events")
      @core.api_path(cli).should == {:path=>"/events", :method=>"Get", :command=>"events", :payload=>false}
    end

    it 'can return all events for a client path' do
      cli = {
        :command => 'events',
        :method => 'Get',
        :fields => {:client => 'test'}
      }
      @core.instance_variable_set(:@command, "events")
      @core.api_path(cli).should == {:path=>"/events/test", :method=>"Get", :command=>"events", :payload=>false}
    end

    it 'can return all specific event for a client path' do
      cli = {
        :command => 'events',
        :method => 'Get',
        :fields => {:client => 'test', :check => 'check'}
      }
      @core.instance_variable_set(:@command, "events")
      @core.api_path(cli).should == {:path=>"/events/test/check", :method=>"Get", :command=>"events", :payload=>false}
    end

    it 'can return all proper client resolve path' do
      cli = {
        :command => 'resolve',
        :method => 'Post',
        :fields => {:client => "test"}
      }
      @core.instance_variable_set(:@command, "resolve")
      payload = {:client => "test", :check => nil}.to_json
      @core.api_path(cli).should == {:path=>"/event/resolve", :method=>"Post", :command=>"resolve", :payload=>payload}
    end

    it 'can return all proper client/check resolve path' do
      cli = {
        :command => 'resolve',
        :method => 'Post',
        :fields => {:client => "test", :check => 'check'}
      }
      @core.instance_variable_set(:@command, "resolve")
      payload = {:client => "test", :check => 'check'}.to_json
      @core.api_path(cli).should == {:path=>"/event/resolve", :method=>"Post", :command=>"resolve", :payload=>payload}
    end

    it 'can return all aggregates path' do
      cli = {
        :command => 'aggregates',
        :method => 'Get',
        :fields => {}
      }
      @core.instance_variable_set(:@command, "aggregates")
      @core.api_path(cli).should == {:path=>"/aggregates", :method=>"Get", :command=>"aggregates", :payload=>false}
    end

    it 'can return aggregates check path' do
      cli = {
        :command => 'aggregates',
        :method => 'Get',
        :fields => {:check => 'check'}
      }
      @core.instance_variable_set(:@command, "aggregates")
      @core.api_path(cli).should == {:path=>"/aggregates/check", :method=>"Get", :command=>"aggregates", :payload=>false}
    end

    it 'can return aggregates check path with id' do
      cli = {
        :command => 'aggregates',
        :method => 'Get',
        :fields => {:check => 'check', :id => 234234234}
      }
      @core.instance_variable_set(:@command, "aggregates")
      @core.api_path(cli).should == {:path=>"/aggregates/check/234234234", :method=>"Get", :command=>"aggregates", :payload=>false}
    end

    it 'can return silence client path' do
      cli = {
        :command => 'silence',
        :method => 'Post',
        :fields => {:client => 'client'}
      }
      @core.instance_variable_set(:@command, "silence")
      payload = {:timestamp => Time.now.to_i}.to_json
      @core.api_path(cli).should == {:path=>"/stashes/silence/client", :method=>"Post", :command=>"silence", :payload=>payload}
    end

    it 'can return silence client/check path' do
      cli = {
        :command => 'silence',
        :method => 'Post',
        :fields => {:client => 'client', :check => 'check'}
      }
      @core.instance_variable_set(:@command, "silence")
      payload = {:timestamp => Time.now.to_i}.to_json
      @core.api_path(cli).should == {:path=>"/stashes/silence/client/check", :method=>"Post", :command=>"silence", :payload=>payload}
    end

    it 'can return silence client/check with reason and expires path' do
      cli = {
        :command => 'silence',
        :method => 'Post',
        :fields => {:client => 'client', :check => 'check', :reason => 'noisy client', :expires => 30}
      }
      @core.instance_variable_set(:@command, "silence")
      payload = {:timestamp => Time.now.to_i, :reason => 'noisy client', :expires => (Time.now.to_i + (30*60))}.to_json
      @core.api_path(cli).should == {:path=>"/stashes/silence/client/check", :method=>"Post", :command=>"silence", :payload=>payload}
    end

  end

  describe 'settings' do
    it 'can setup settings' do
      @core.settings
      SensuCli::Config.host.should match(/^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/)
      SensuCli::Config.port.should eq('4567')
      SensuCli::Config.ssl.should satisfy { true || false}
    end
  end

  describe 'response codes' do
    it 'can handle a 200 response code' do
      response = '{"sensu":{"version":"0.9.12"},"rabbitmq":{"keepalives":{"messages":0,"consumers":1},"results":{"messages":0,"consumers":1},"connected":true},"redis":{"connected":true}}'
      output = @core.response_codes('200',response)
      output.should == {"sensu"=>{"version"=>"0.9.12"}, "rabbitmq"=>{"keepalives"=>{"messages"=>0, "consumers"=>1}, "results"=>{"messages"=>0, "consumers"=>1}, "connected"=>true}, "redis"=>{"connected"=>true}}
    end

    it 'can handle a 201 response code for stashes endpoint' do
      @core.instance_variable_set(:@command, "stashes")
      output = capture_stdout { @core.response_codes('201',"") }
      output.should == "The stash has been created.\n"
    end

    it 'can handle a 202 response code' do
      output = capture_stdout { @core.response_codes('202',"") }
      output.should == "The item was submitted for processing.\n"
    end

    it 'can handle a 204 response code for health endpoint' do
      @core.instance_variable_set(:@command, "health")
      output = capture_stdout { @core.response_codes('204',"") }
      output.should == "Sensu is healthy\n"
    end

    it 'can handle a 204 response code for aggregates endpoint' do
      @core.instance_variable_set(:@command, "aggregates")
      output = capture_stdout { @core.response_codes('204',"") }
      output.should == "The item was successfully deleted.\n"
    end

    it 'can handle a 204 response code for stashes endpoint' do
      @core.instance_variable_set(:@command, "stashes")
      output = capture_stdout { @core.response_codes('204',"") }
      output.should == "The item was successfully deleted.\n"
    end

    it 'can handle a 400 response code' do
      output = capture_stdout { @core.response_codes('400',"") }
      output.should == "\e[31mThe payload is malformed.\e[0m\n"
    end

    it 'can handle a 401 response code' do
      output = capture_stdout { @core.response_codes('401',"") }
      output.should == "\e[31mThe request requires user authentication.\e[0m\n"
    end

    it 'can handle a 404 response code' do
      output = capture_stdout { @core.response_codes('404',"") }
      output.should == "\e[36mThe item did not exist.\e[0m\n"
    end

    it 'can handle a other (500) response codes' do
      output = capture_stdout { @core.response_codes('500',"") }
      output.should == "\e[31mThere was an error while trying to complete your request. Response code: 500\e[0m\n"
    end

    it 'can handle a failed health check response code' do
      @core.instance_variable_set(:@command, "health")
      output = capture_stdout { @core.response_codes('503',"") }
      output.should == "\e[31mSensu is not healthy.\e[0m\n"
    end
  end

end
