require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Railshoster::InitCommand do
  
  before do
    # We use the gem's dir as this should be a valid git repo
    @git_dir = File.join(File.dirname(__FILE__), "..", "..", "..")    
    # @init = Railshoster::InitCommand.new(@git_dir, '{"t":"v","u":"rails1","a":"rails1","aid":1, "h":"server1717.railsvserver.de","p":"xxx"}')
  end
  
  describe "#Git" do     
    
    #TODO
    it "should do sth useful if the given project dir has no remote url" do
      pending("handle this situation in code an spec.")
    end
  end
    
  describe "#run_by_application_hash" do
    it "should create a deploy rb and capify the project" do
      pending("use fakefs to test this.")
    end
    
    it "should deny to run for a non-git project dir" do
      pending("not git -> no repo url -> no deploy rb -> fail")
    end
    
    it "should gracefully die for a git project dir without a remote origin" do
      pending("no remote origin -> no repo url -> no deploy rb -> fail")
    end
    
    it "should raise an BadApplicationJSONHashError error for an invalid incoming JSON hash" do      
      @init = Railshoster::InitCommand.new(@git_dir, '')
      expect { @init.send(:parse_application_json_hash, '') }.to raise_error(Railshoster::BadApplicationJSONHashError)
    end
  end
  
  describe "#run_by_application_token" do
    it "should create a deploy rb and capify the project" do
      pending("use fakefs to test this.")
    end
    
    it "should raise an BadApplicationTokenError error for an invalid incoming application token" do      
      expect { Railshoster::InitCommand.run_by_application_token(@git_dir, "abab") }.to raise_error(Railshoster::BadApplicationTokenError)
    end
  end
end