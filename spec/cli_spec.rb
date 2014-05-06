require File.dirname(__FILE__) + '/../lib/sensu-cli/cli.rb'
require File.dirname(__FILE__) + '/helpers.rb'

describe 'SensuCli::Cli' do
  include Helpers

  before(:each) do
    ARGV.clear
  end

  before do
    @cli = SensuCli::Cli.new
  end

  describe 'global' do
    it 'should return help with no ARGVs' do
      -> { @cli.global }.should raise_error SystemExit
    end
  end

  describe 'client commands' do
    it 'should return client help with no args' do
      ARGV.push('client')
      -> { @cli.global }.should raise_error SystemExit
    end

    it 'should return client help with --help' do
      ARGV.push('client', '--help')
      -> { @cli.global }.should raise_error SystemExit
    end

    it 'should return proper client list hash' do
      ARGV.push('client', 'list')
      response = @cli.global
      response.should eq({ :command => 'clients', :method => 'Get', :fields => {
        :limit => nil, :offset => nil, :format => nil, :fields => nil, :filter => nil, :help => false } })
    end

    it 'should return proper client show hash' do
      ARGV.push('client', 'show', 'test_client')
      response = @cli.global
      response.should eq({ :command => 'clients', :method => 'Get', :fields => {
        :name => 'test_client', :help => false } })
    end

    it 'should return proper client delete hash' do
      ARGV.push('client', 'delete', 'test_client')
      response = @cli.global
      response.should eq({ :command => 'clients', :method => 'Delete', :fields => {
        :name => 'test_client', :help => false } })
    end

    it 'should return proper client history hash' do
      ARGV.push('client', 'history', 'test_client')
      response = @cli.global
      response.should eq({ :command => 'clients', :method => 'Get', :fields => {
        :name => 'test_client', :history => true, :help => false } })
    end

    it 'should paginate with limit and offset' do
      ARGV.push('client', 'list', '-l', '2', '-o', '3')
      response = @cli.global
      response.should eq({ :command => 'clients', :method => 'Get', :fields => {
        :limit => '2', :offset => '3', :format => nil, :fields => nil, :filter => nil, :help => false, :limit_given => true, :offset_given => true } })
    end

    it 'should paginate with limit' do
      ARGV.push('client', 'list', '-l', '2')
      response = @cli.global
      response.should eq({ :command => 'clients', :method => 'Get', :fields => {
        :limit => '2', :offset => nil, :format => nil, :fields => nil, :filter => nil, :help => false, :limit_given => true } })
    end

    it 'should bail if offset exists without limit' do
      ARGV.push('client', 'list', '-o', '2')
      -> { @cli.global }.should raise_error SystemExit
    end
  end

  describe 'info commands' do
    it 'should return proper info hash' do
      ARGV.push('info')
      response = @cli.global
      response.should eq({ :command => 'info', :method => 'Get', :fields => {
        :help => false } })
    end
  end

  describe 'health commands' do
    it 'should return proper health hash' do
      ARGV.push('health', '--messages', '3', '--consumers', '2')
      response = @cli.global
      response.should eq({ :command => 'health', :method => 'Get', :fields => {
        :consumers => '2', :messages => '3', :help => false, :messages_given => true, :consumers_given => true } })
    end
  end

  describe 'aggregate commands' do
    it 'should return aggregate help' do
      ARGV.push('aggregate', '--help')
      -> { @cli.global }.should raise_error SystemExit
    end

    it 'should return proper aggregate list hash' do
      ARGV.push('aggregate', 'list')
      response = @cli.global
      response.should eq({ :command => 'aggregates', :method => 'Get', :fields => {
        :help => false } })
    end

    it 'should return proper aggregate delete hash' do
      ARGV.push('aggregate', 'delete', 'test_check')
      response = @cli.global
      response.should eq({ :command => 'aggregates', :method => 'Delete', :fields => {
        :check =>  'test_check', :help => false } })
    end

    it 'should return proper aggregate show hash' do
      ARGV.push('aggregate', 'show', 'test_check')
      response = @cli.global
      response.should eq({ :command => 'aggregates', :method => 'Get', :fields => {
        :check => 'test_check', :id => nil, :limit => nil, :offset => nil, :help => false } })
    end

    it 'should return proper aggregate show hash with id' do
      ARGV.push('aggregate', 'show', 'test_check', '--id', '1231231231')
      response = @cli.global
      response.should eq({ :command => 'aggregates', :method => 'Get', :fields => {
        :check => 'test_check', :id => 1231231231, :limit => nil, :offset => nil, :help => false, :id_given => true } })
    end

    it 'should paginate with limit and offset' do
      ARGV.push('aggregate', 'show', 'test_check', '-l', '2', '-o', '3')
      response = @cli.global
      response.should eq({ :command => 'aggregates', :method => 'Get', :fields => {
        :check => 'test_check', :id => nil, :limit => '2', :offset => '3', :help => false, :limit_given => true, :offset_given => true } })
    end

    it 'should paginate with limit' do
      ARGV.push('aggregate', 'show', 'test_check', '-l', '2')
      response = @cli.global
      response.should eq({ :command => 'aggregates', :method => 'Get', :fields => {
        :check => 'test_check', :id => nil, :limit => '2', :offset => nil, :help => false, :limit_given => true } })
    end

    it 'should bail with offset and no limit' do
      ARGV.push('aggregate', 'show', 'test_check', '-o', '2')
      -> { @cli.global }.should raise_error SystemExit
    end
  end

  describe 'check commands' do
    it 'should return check help' do
      ARGV.push('check', '--help')
      -> { @cli.global }.should raise_error SystemExit
    end

    it 'should return check list hash' do
      ARGV.push('check', 'list')
      response = @cli.global
      response.should eq({ :command => 'checks', :method => 'Get', :fields => {
        :help => false } })
    end

    it 'should return check show hash' do
      ARGV.push('check', 'show', 'test_check')
      response = @cli.global
      response.should eq({ :command => 'checks', :method => 'Get', :fields => {
        :name => 'test_check', :help => false } })
    end

    it 'should return check request hash' do
      ARGV.push('check', 'request', 'test_check', 'all,web')
      response = @cli.global
      response.should eq({ :command => 'checks', :method => 'Post', :fields => {
        :check => 'test_check', :subscribers => ['all', 'web'], :help => false } }) # rubocop:disable WordArray
    end
  end

  describe 'event commands' do
    it 'should return event help' do
      ARGV.push('event', '--help')
      -> { @cli.global }.should raise_error SystemExit
    end

    it 'should return event list hash' do
      ARGV.push('event', 'list')
      response = @cli.global
      response.should eq({ :command => 'events', :method => 'Get', :fields => {
        :format => nil, :help => false } })
    end

    it 'should return event show node hash' do
      ARGV.push('event', 'show', 'test_node')
      response = @cli.global
      response.should eq({ :command => 'events', :method => 'Get', :fields => {
        :client => 'test_node', :check => nil, :help => false } })
    end

    it 'should return event show node check hash' do
      ARGV.push('event', 'show', 'test_node', '-k', 'test_check')
      response = @cli.global
      response.should eq({ :command => 'events', :method => 'Get', :fields => {
        :client => 'test_node', :check => 'test_check', :help => false, :check_given => true } })
    end

    it 'should return event delete node check hash' do
      ARGV.push('event', 'delete', 'test_node', 'test_check')
      response = @cli.global
      response.should eq({ :command => 'events', :method => 'Delete', :fields => {
        :client => 'test_node', :check => 'test_check', :help => false } })
    end
  end

  describe 'silence commands' do
    it 'should return event help' do
      ARGV.push('silence', '--help')
      -> { @cli.global }.should raise_error SystemExit
    end

    it 'should return silence node hash' do
      ARGV.push('silence', 'test_node')
      response = @cli.global
      response.should eq({ :command => 'silence', :method => 'Post', :fields => {
        :client => 'test_node', :check => nil, :owner => nil, :reason => nil, :expire =>  nil, :help => false } })
    end

    it 'should return silence node check hash' do
      ARGV.push('silence', 'test_node', '-k', 'test_check')
      response = @cli.global
      response.should eq({ :command => 'silence', :method => 'Post', :fields => {
        :client => 'test_node', :check => 'test_check', :owner => nil, :reason => nil, :expire =>  nil, :help => false, :check_given => true } })
    end

    it 'should return silence node check hash with options' do
      ARGV.push('silence', 'test_node', '-k', 'test_check', '-r', "it's noisy", '-e', '30')
      response = @cli.global
      response.should eq({ :command => 'silence', :method => 'Post', :fields => {
        :client => 'test_node', :check => 'test_check', :owner => nil, :reason => "it's noisy", :expire => 30,
        :help => false, :check_given => true, :reason_given => true, :expire_given => true } })
    end

  end

  describe 'resolve commands' do
    it 'should return resolve help' do
      ARGV.push('resolve', '--help')
      -> { @cli.global }.should raise_error SystemExit
    end

    it 'should return resolve node check hash' do
      ARGV.push('resolve', 'test_node', 'test_check')
      response = @cli.global
      response.should eq({ :command => 'resolve', :method => 'Post', :fields => {
        :client => 'test_node', :check => 'test_check', :help => false } })
    end
  end

  describe 'stash commands' do
    it 'should return stash help' do
      ARGV.push('stash', '--help')
      -> { @cli.global }.should raise_error SystemExit
    end

    it 'should return stash list hash' do
      ARGV.push('stash', 'list')
      response = @cli.global
      response.should eq({ :command => 'stashes', :method => 'Get', :fields => {
        :limit => nil, :offset => nil, :format => nil, :help => false } })
    end

    it 'should return stash show hash' do
      ARGV.push('stash', 'show', 'path')
      response = @cli.global
      response.should eq({ :command => 'stashes', :method => 'Get', :fields => {
        :path => 'path', :help => false } })
    end

    it 'should return stash delete hash' do
      ARGV.push('stash', 'delete', 'path')
      response = @cli.global
      response.should eq({ :command => 'stashes', :method => 'Delete', :fields => {
        :path => 'path', :help => false } })
    end

    it 'should return stash create hash' do
      ARGV.push('stash', 'create', 'path')
      response = @cli.global
      response.should eq({ :command => 'stashes', :method => 'Post', :fields => {
        :create  =>  true, :create_path  =>  'path', :help  =>  false } })
    end

    it 'should paginate with limit and offset' do
      ARGV.push('stash', 'list', '-l', '2', '-o', '3')
      response = @cli.global
      response.should eq({ :command => 'stashes', :method => 'Get', :fields => {
        :limit => '2', :offset => '3', :format => nil, :help => false, :limit_given => true, :offset_given => true } })
    end

    it 'should paginate with limit' do
      ARGV.push('stash', 'list', '-l', '2')
      response = @cli.global
      response.should eq({ :command => 'stashes', :method => 'Get', :fields => {
        :limit => '2', :offset => nil, :format => nil, :help => false, :limit_given => true } })
    end

    it 'should bail with offset and no limit' do
      ARGV.push('stash', 'list', '-o', '2')
      -> { @cli.global }.should raise_error SystemExit
    end
  end

end
