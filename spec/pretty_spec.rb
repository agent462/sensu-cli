require File.dirname(__FILE__) + '/../lib/sensu-cli/pretty.rb'
require File.dirname(__FILE__) + '/helpers.rb'
require 'json'

describe 'SensuCli::Pretty' do
  include Helpers

  describe 'pretty text' do
    it 'can pretty empty response' do
      res = []
      output = capture_stdout { SensuCli::Pretty.print(res) }
      output.should == "\e[36mno values for this request\e[0m\n"
    end

    it 'can pretty a hash' do
      res = [{ :test => 'value' }]
      output = capture_stdout { SensuCli::Pretty.print(res) }
      output.should == "\e[33m-------\e[0m\n\e[36mtest:  \e[0m\e[32mvalue\e[0m\n"
    end

    it 'can pretty an array' do
      res = ['test', 'test1']
      output = capture_stdout { SensuCli::Pretty.print(res) }
      output.should == "\e[33m-------\e[0m\n\e[36mtest\e[0m\n\e[33m-------\e[0m\n\e[36mtest1\e[0m\n"
    end

    it 'can pretty a hash inside an array' do
      res = [{ :test => 'value', :test1 => 'value1' }]
      output = capture_stdout { SensuCli::Pretty.print(res) }
      output.should == "\e[33m-------\e[0m\n\e[36mtest:  \e[0m\e[32mvalue\e[0m\n\e[36mtest1:  \e[0m\e[32mvalue1\e[0m\n"
    end
  end

  describe 'pretty table' do
    it 'can table an empty response' do
      res = []
      output = capture_stdout { SensuCli::Pretty.table(res) }
      output.should == "\e[36mno values for this request\e[0m\n"
    end

    it 'can table a hash inside an array' do
      res = [{ :test => 'value', :test1 => 'value1' }]
      output = capture_stdout { SensuCli::Pretty.table(res) }
      output.should == "test  test1 \nvalue value1\n"
    end

  end

  describe 'count response' do
    it 'can count a hash' do
      res = { :test => 'value', :test1 => 'value1' }
      output = capture_stdout { SensuCli::Pretty.count(res) }
      output.should == "\e[33m2 total items\e[0m\n"
    end

    it 'can count an array' do
      res = ['test', 'test2']
      output = capture_stdout { SensuCli::Pretty.count(res) }
      output.should == "\e[33m2 total items\e[0m\n"
    end
  end

end
