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
  end
end