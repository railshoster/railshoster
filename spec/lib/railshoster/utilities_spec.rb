require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Railshoster::Utilities do  
    
  describe "#Backup" do    
    
    before do
       FakeFS.activate!
    end
    
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
    
    after do
      FakeFS.deactivate!
    end        
  end
    
  describe "#ssh_tools" do
    it "should find public ssh keys" do
      # mock Etc.getlogin  -> point to spec folder        
      Railshoster::Utilities.find_public_ssh_keys
    end
    
    it "should verify a valid ssh public key" do
      Railshoster::Utilities.verify_public_ssh_key("ssh-dss AAAAB3NzaC1kc3MAAACASb4K1r69pd07CdApimtQvDD6VfKNCxv3BjyApoG4jQrrzhyMbuu1CKlbn7fIP4b18nQw3j02KIihcK/m6eN3pEkdI2+EbfGdpZeyZsxu7T0TgUDdB5+9wBHK46djOcB9n0PvY+uC/wO+nOXLMaL6dTzPOAF88QKr4Y88QMLzyNcAAAAVAIyNiIdszugwRjAefsa+JhGv+DR7AAAAgBonQljDlrI71sryROfA0KCu+wzB2mhou1iJEuFu0X079Urs6vhniT0qNXHMhLHFCxfZTrjbAGM3PY1SjW2XKmPLfyDwWoJrKtB10WZSlGZqSajMHahFdQ0fruibR/jGPI/etWbMSOHNZ2bBrM19LzuxPoZ2yWdigfCTLNl0bct6AAAAgDjakQkN1VfL/qFaAaX9VNS91ztUZo7HW2XuarGQ8GlTANsfWRhJLwXGJXkFaLB3Ja8DFeBLdnNBLKlMBh0MUIxOryrR6ShC5Ul5bmWfzpHq9WyTF6G/qmm7dIOSFJpe5OfAaZitaNjb7dHe6ruryYZ9IuPwuKWwy+BNJih+EEFJ")
      pending("implement Railshoster::Utilities.verify_public_ssh_key")
    end
    
    it "should fail to verify a ssh key without a public key format identifier" do
      expect {
        Railshoster::Utilities.verify_public_ssh_key("AAAAB3NzaC1kc3MAAACASb4K1r69pd07CdApimtQvDD6VfKNCxv3BjyApoG4jQrrzhyMbuu1CKlbn7fIP4b18nQw3j02KIihcK/m6eN3pEkdI2+EbfGdpZeyZsxu7T0TgUDdB5+9wBHK46djOcB9n0PvY+uC/wO+nOXLMaL6dTzPOAF88QKr4Y88QMLzyNcAAAAVAIyNiIdszugwRjAefsa+JhGv+DR7AAAAgBonQljDlrI71sryROfA0KCu+wzB2mhou1iJEuFu0X079Urs6vhniT0qNXHMhLHFCxfZTrjbAGM3PY1SjW2XKmPLfyDwWoJrKtB10WZSlGZqSajMHahFdQ0fruibR/jGPI/etWbMSOHNZ2bBrM19LzuxPoZ2yWdigfCTLNl0bct6AAAAgDjakQkN1VfL/qFaAaX9VNS91ztUZo7HW2XuarGQ8GlTANsfWRhJLwXGJXkFaLB3Ja8DFeBLdnNBLKlMBh0MUIxOryrR6ShC5Ul5bmWfzpHq9WyTF6G/qmm7dIOSFJpe5OfAaZitaNjb7dHe6ruryYZ9IuPwuKWwy+BNJih+EEFJ")
      }.to raise_error(Railshoster::InvalidPublicSshKeyError)
    end
    
    it "should fail to verify a ssh key without a public key/certificate data" do
      expect {
        Railshoster::Utilities.verify_public_ssh_key("ssh-dss ")
      }.to raise_error(Railshoster::InvalidPublicSshKeyError)
    end
  end  
end