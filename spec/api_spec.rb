require File.dirname(__FILE__) + '/../lib/sensu-cli/api.rb'
require File.dirname(__FILE__) + '/helpers.rb'

describe 'SensuCli::Api' do
  include Helpers

  before do
    @core = SensuCli::Api.new
  end

  describe 'response codes' do
    it 'can handle a 200 response code' do
      response = '{"sensu":{"version":"0.9.12"},"rabbitmq":{"keepalives":{"messages":0,"consumers":1},'\
        '"results":{"messages":0,"consumers":1},"connected":true},"redis":{"connected":true}}'
      output = @core.response('200', response)
      output.should == { 'sensu' => { 'version' => '0.9.12' }, 'rabbitmq' => { 'keepalives' => { 'messages' => 0, 'consumers' => 1 }, 'results' => { 'messages' => 0, 'consumers' => 1 }, 'connected' => true }, 'redis' => { 'connected' => true } }
    end

    it 'can handle a 201 response code for stashes endpoint' do
      command = 'stashes'
      output = capture_stdout { @core.response('201', '', command) }
      output.should == "The stash has been created.\n"
    end

    it 'can handle a 202 response code' do
      output = capture_stdout { @core.response('202', '') }
      output.should == "The item was submitted for processing.\n"
    end

    it 'can handle a 204 response code for health endpoint' do
      command = 'health'
      output = capture_stdout { @core.response('204', '', command) }
      output.should == "Sensu is healthy\n"
    end

    it 'can handle a 204 response code for aggregates endpoint' do
      command = 'aggregates'
      output = capture_stdout { @core.response('204', '', command) }
      output.should == "The item was successfully deleted.\n"
    end

    it 'can handle a 204 response code for stashes endpoint' do
      command = 'stashes'
      output = capture_stdout { @core.response('204', '', command) }
      output.should == "The item was successfully deleted.\n"
    end

    it 'can handle a 400 response code' do
      output = capture_stdout { @core.response('400', '') }
      output.should == "\e[31mThe payload is malformed.\e[0m\n"
    end

    it 'can handle a 401 response code' do
      output = capture_stdout { @core.response('401', '') }
      output.should == "\e[31mThe request requires user authentication.\e[0m\n"
    end

    it 'can handle a 404 response code' do
      output = capture_stdout { @core.response('404', '') }
      output.should == "\e[36mThe item did not exist.\e[0m\n"
    end

    it 'can handle a other (500) response codes' do
      output = capture_stdout { @core.response('500', '') }
      output.should == "\e[31mThere was an error while trying to complete your request. Response code: 500\e[0m\n"
    end

    it 'can handle a failed health check response code' do
      command = 'health'
      output = capture_stdout { @core.response('503', '', command) }
      output.should == "\e[31mSensu is not healthy.\e[0m\n"
    end
  end

end
