require File.join(File.dirname(__FILE__), "..", "..", "spec_helper.rb")

describe RailsHoster::Command do
  it "should instanciate a Command instance also initializing the project git repo" do

    # We use the gem's dir as this should be a valid git repo
    git_dir = File.join(File.dirname(__FILE__), "..", "..")
    expect { c = Command.new(git_dir) }.to_not raise_error(Railshoster::PossiblyNotAGitRepoError)
  end
end