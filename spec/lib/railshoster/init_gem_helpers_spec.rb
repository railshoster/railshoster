require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Railshoster::InitGemHelpers do
  
  # Evil: Create a fake class to test the module.
  class MyInitGemHelpersTestClass
    include Railshoster::InitGemHelpers
    
    def initialize(project_dir)
      @project_dir = project_dir
    end
  end  
  
  describe "#Mysql2" do         
    before do    
      @cl = MyInitGemHelpersTestClass.new(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "bundler", "mysql2"))
    end
    
    it "should determine a valid Gemfile.lock path" do      
      @cl.send(:gemfilelock_filepath).should eql(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "bundler", "mysql2", "Gemfile.lock"))
    end
    
    it "should extract the database gem from the Gemfile.lock file" do      
      @cl.send(:get_db_gem).name.should eql("mysql2")
    end
  end
  
  describe "#Mysql" do         
    before do    
      @cl = MyInitGemHelpersTestClass.new(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "bundler", "mysql"))
    end
    
    it "should determine a valid Gemfile.lock path" do      
      @cl.send(:gemfilelock_filepath).should eql(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "bundler", "mysql", "Gemfile.lock"))
    end
    
    it "should extract the database gem from the Gemfile.lock file" do      
      @cl.send(:get_db_gem).name.should eql("mysql")
    end
  end
  
  describe "#Postgres" do         
    before do    
      @cl = MyInitGemHelpersTestClass.new(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "bundler", "pg"))
    end
    
    it "should determine a valid Gemfile.lock path" do      
      @cl.send(:gemfilelock_filepath).should eql(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "bundler", "pg", "Gemfile.lock"))
    end
    
    it "should extract the database gem from the Gemfile.lock file" do      
      expect { @cl.send(:get_db_gem) }.to raise_error
    end
  end
end