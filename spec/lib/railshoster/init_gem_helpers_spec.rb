require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Railshoster::InitGemHelpers do
  
  # Evil: Create a fake class to test the module.
  class MyInitGemHelpersTestClass
    include Railshoster::InitGemHelpers
    
    def initialize
      @project_dir = File.join(File.dirname(__FILE__), "..", "..", "fakefs", "bundler")
    end
  end
  
  before do    
    @cl = MyInitGemHelpersTestClass.new
  end
  
  describe "#Git" do     
    it "should determine a valid Gemfile.lock path" do
      @cl.send(:gemfilelock_filepath).should eql(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "bundler", "Gemfile.lock"))
    end
    
    it "should extract the database gem from the Gemfile.lock file" do
      @cl.send(:get_db_gem).name.should eql("mysql2")
    end
  end
  
end