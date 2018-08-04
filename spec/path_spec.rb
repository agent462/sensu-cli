require 'sensu-cli/path'

describe 'SensuCli::PathParser' do
  include Helpers

  before do
    @parse = SensuCli::PathCreator.new
  end

  describe 'pagination' do
    it 'can paginate with limit and offset' do
      cli = { :fields => { :limit => '2', :offset => '3' } }
      output = @parse.pagination(cli)
      output.should == '?limit=2&offset=3'
    end

    it 'can paginate with limit' do
      cli = { :fields => { :limit => '2' } }
      output = @parse.pagination(cli)
      output.should == '?limit=2'
    end

    it 'can return empty string if offset and limit do not exist' do
      cli = { :fields => {} }
      output = @parse.pagination(cli)
      output.should == ''
    end
  end

end
