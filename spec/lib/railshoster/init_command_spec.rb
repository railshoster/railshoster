require File.join(File.dirname(__FILE__), "..", "..", "spec_helper.rb")

describe Railshoster::InitCommand do
  
  before do
    # We use the gem's dir as this should be a valid git repo
    git_dir = File.join(File.dirname(__FILE__), "..", "..", "..")    
    @init = Railshoster::InitCommand.new(git_dir)
  end
  
  describe "#Git" do 
    it "should read the git repo url" do
      @init.send(:get_git_remote_url_from_git_config).should eql("git@github.com:railshoster/railshoster.git")
    end
    
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
  end
  
  describe "#run_by_application_token" do
    it "should create a deploy rb and capify the project" do
      pending("use fakefs to test this.")
    end
  end
end