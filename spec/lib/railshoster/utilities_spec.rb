require File.join(File.dirname(__FILE__), "..", "..", "spec_helper.rb")

describe Railshoster::Utilities do  
  
  before do
     FakeFS.activate!
  end
  
  describe "#Backup" do    
    include FakeFS::SpecHelpers
    
    it "should create a backup file" do     
      File.new("myfile.txt", "w+")
      File.exists?("myfile.txt").should be_true
      expect { Railshoster::Utilities.backup_file("myfile.txt") }.to_not raise_error
      File.exists?("myfile.txt").should be_true
      File.exists?("myfile.txt.bak").should be_true
    end
    
    it "should create a backup of a backup file and then backup the file" do
      
      # File to be backed up
      File.open("myfile.txt", "w+") do |f|
        f << "1"
      end
      
      # We assume there is already an older backup
      File.open("myfile.txt.bak", "w+") do |f|
        f << "2"
      end            
      expect { Railshoster::Utilities.backup_file("myfile.txt") }.to_not raise_error
      File.exists?("myfile.txt").should be_true
      File.exists?("myfile.txt.bak").should be_true
      File.exists?("myfile.txt.bak.bak").should be_true
      
      File.open("myfile.txt").read.should eql("1")
      
      # .bak after backing up is the newest backup
      File.open("myfile.txt.bak").read.should eql("1")
      
      # But the old backup is still there - being moved to .bak.bak.
      File.open("myfile.txt.bak.bak").read.should eql("2")
    end
  end 
  
  after do
    FakeFS.deactivate!
  end
end