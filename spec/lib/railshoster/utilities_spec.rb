require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Railshoster::Utilities do  
    
  describe "#Backup" do    
    
    before do
       FakeFS.activate!
    end
    
    include FakeFS::SpecHelpers
    
    it "should create a backup file" do     
      File.new("myfile.txt", "w+")
      File.exists?("myfile.txt").should be(true)
      expect { Railshoster::Utilities.backup_file("myfile.txt") }.to_not raise_error
      File.exists?("myfile.txt").should be(true)
      File.exists?("myfile.txt.bak").should be(true)
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
      File.exists?("myfile.txt").should be(true)
      File.exists?("myfile.txt.bak").should be(true)
      File.exists?("myfile.txt.bak.bak").should be(true)
      
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
    it "should parse a valid ssh public key" do
      key = Railshoster::Utilities.parse_public_ssh_key("ssh-dss AAAAB3NzaC1kc3MAAACASb4K1r69pd07CdApimtQvDD6VfKNCxv3BjyApoG4jQrrzhyMbuu1CKlbn7fIP4b18nQw3j02KIihcK/m6eN3pEkdI2+EbfGdpZeyZsxu7T0TgUDdB5+9wBHK46djOcB9n0PvY+uC/wO+nOXLMaL6dTzPOAF88QKr4Y88QMLzyNcAAAAVAIyNiIdszugwRjAefsa+JhGv+DR7AAAAgBonQljDlrI71sryROfA0KCu+wzB2mhou1iJEuFu0X079Urs6vhniT0qNXHMhLHFCxfZTrjbAGM3PY1SjW2XKmPLfyDwWoJrKtB10WZSlGZqSajMHahFdQ0fruibR/jGPI/etWbMSOHNZ2bBrM19LzuxPoZ2yWdigfCTLNl0bct6AAAAgDjakQkN1VfL/qFaAaX9VNS91ztUZo7HW2XuarGQ8GlTANsfWRhJLwXGJXkFaLB3Ja8DFeBLdnNBLKlMBh0MUIxOryrR6ShC5Ul5bmWfzpHq9WyTF6G/qmm7dIOSFJpe5OfAaZitaNjb7dHe6ruryYZ9IuPwuKWwy+BNJih+EEFJ")      
      key[:format].should eql("ssh-dss")
      key[:key_data].should eql("AAAAB3NzaC1kc3MAAACASb4K1r69pd07CdApimtQvDD6VfKNCxv3BjyApoG4jQrrzhyMbuu1CKlbn7fIP4b18nQw3j02KIihcK/m6eN3pEkdI2+EbfGdpZeyZsxu7T0TgUDdB5+9wBHK46djOcB9n0PvY+uC/wO+nOXLMaL6dTzPOAF88QKr4Y88QMLzyNcAAAAVAIyNiIdszugwRjAefsa+JhGv+DR7AAAAgBonQljDlrI71sryROfA0KCu+wzB2mhou1iJEuFu0X079Urs6vhniT0qNXHMhLHFCxfZTrjbAGM3PY1SjW2XKmPLfyDwWoJrKtB10WZSlGZqSajMHahFdQ0fruibR/jGPI/etWbMSOHNZ2bBrM19LzuxPoZ2yWdigfCTLNl0bct6AAAAgDjakQkN1VfL/qFaAaX9VNS91ztUZo7HW2XuarGQ8GlTANsfWRhJLwXGJXkFaLB3Ja8DFeBLdnNBLKlMBh0MUIxOryrR6ShC5Ul5bmWfzpHq9WyTF6G/qmm7dIOSFJpe5OfAaZitaNjb7dHe6ruryYZ9IuPwuKWwy+BNJih+EEFJ")
      key[:key].should eql("ssh-dss AAAAB3NzaC1kc3MAAACASb4K1r69pd07CdApimtQvDD6VfKNCxv3BjyApoG4jQrrzhyMbuu1CKlbn7fIP4b18nQw3j02KIihcK/m6eN3pEkdI2+EbfGdpZeyZsxu7T0TgUDdB5+9wBHK46djOcB9n0PvY+uC/wO+nOXLMaL6dTzPOAF88QKr4Y88QMLzyNcAAAAVAIyNiIdszugwRjAefsa+JhGv+DR7AAAAgBonQljDlrI71sryROfA0KCu+wzB2mhou1iJEuFu0X079Urs6vhniT0qNXHMhLHFCxfZTrjbAGM3PY1SjW2XKmPLfyDwWoJrKtB10WZSlGZqSajMHahFdQ0fruibR/jGPI/etWbMSOHNZ2bBrM19LzuxPoZ2yWdigfCTLNl0bct6AAAAgDjakQkN1VfL/qFaAaX9VNS91ztUZo7HW2XuarGQ8GlTANsfWRhJLwXGJXkFaLB3Ja8DFeBLdnNBLKlMBh0MUIxOryrR6ShC5Ul5bmWfzpHq9WyTF6G/qmm7dIOSFJpe5OfAaZitaNjb7dHe6ruryYZ9IuPwuKWwy+BNJih+EEFJ")
    end
    
    it "should fail to parse a ssh key without a public key format identifier" do
      expect {
        Railshoster::Utilities.parse_public_ssh_key("AAAAB3NzaC1kc3MAAACASb4K1r69pd07CdApimtQvDD6VfKNCxv3BjyApoG4jQrrzhyMbuu1CKlbn7fIP4b18nQw3j02KIihcK/m6eN3pEkdI2+EbfGdpZeyZsxu7T0TgUDdB5+9wBHK46djOcB9n0PvY+uC/wO+nOXLMaL6dTzPOAF88QKr4Y88QMLzyNcAAAAVAIyNiIdszugwRjAefsa+JhGv+DR7AAAAgBonQljDlrI71sryROfA0KCu+wzB2mhou1iJEuFu0X079Urs6vhniT0qNXHMhLHFCxfZTrjbAGM3PY1SjW2XKmPLfyDwWoJrKtB10WZSlGZqSajMHahFdQ0fruibR/jGPI/etWbMSOHNZ2bBrM19LzuxPoZ2yWdigfCTLNl0bct6AAAAgDjakQkN1VfL/qFaAaX9VNS91ztUZo7HW2XuarGQ8GlTANsfWRhJLwXGJXkFaLB3Ja8DFeBLdnNBLKlMBh0MUIxOryrR6ShC5Ul5bmWfzpHq9WyTF6G/qmm7dIOSFJpe5OfAaZitaNjb7dHe6ruryYZ9IuPwuKWwy+BNJih+EEFJ")
      }.to raise_error(Railshoster::InvalidPublicSshKeyError)
    end
    
    it "should fail to parse a ssh key without a public key/certificate data" do
      expect {
        Railshoster::Utilities.parse_public_ssh_key("ssh-dss ")
      }.to raise_error(Railshoster::InvalidPublicSshKeyError)
    end
    
    it "should parse a public ssh key file" do      
      keys = Railshoster::Utilities.find_public_ssh_keys(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "fake_dot_ssh", "1_valid_key"), :verbose => false)
      keys.size.should be(1)
      keys.first[:format].should eql("ssh-rsa")
      keys.first[:key_data].should eql("AAAAB3NzaC1yc2EAAAADAQABAAABAQDwnMABQ9xWwYdhHaaoNSzFMfXmytWHgkBmDg6v8Fn3oILqOMs99IPd7ChPetDdUWYV2pzLVVKB/kwrcoodRC4H6YHn8xk1oI+gDsv4Yg7ytWwgnDf5zXwWMVQ/IqfOdfxRwS1UCrKL7UsVfIUPzXmkia7PoMoQNnM8jbDRDcfyis3Q1VZ9OjIlM/RfqjH0hGFS95nd6geNwpSbSpg4HxNmfltQ6GpoqclQXX0QdBO+q93sn33JjFPEhYuLvQcoea7Tl0zRY0AGQ9r7562QFlWqMmB+9YXcsZu2OZSk7t5a39jral0jEuEeJB56kb5ZUqRA1DJI5En09/WUPLCYprdb")
    end
    
    it "should be 0 ssh-keys if the ssh-directory doesn't exists" do
      keys = Railshoster::Utilities.find_public_ssh_keys(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "fake_dot_ssh", "this_does_not_exist"), :verbose => false)
      keys.size.should be(0)
    end
    
    it "should select a public ssh key without a dialog if there is only a single valid key" do 
      key = Railshoster::Utilities.select_public_ssh_key(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "fake_dot_ssh", "1_valid_key"), :verbose => false)
      key[:format].should eql("ssh-rsa")
      key[:key_data].should eql("AAAAB3NzaC1yc2EAAAADAQABAAABAQDwnMABQ9xWwYdhHaaoNSzFMfXmytWHgkBmDg6v8Fn3oILqOMs99IPd7ChPetDdUWYV2pzLVVKB/kwrcoodRC4H6YHn8xk1oI+gDsv4Yg7ytWwgnDf5zXwWMVQ/IqfOdfxRwS1UCrKL7UsVfIUPzXmkia7PoMoQNnM8jbDRDcfyis3Q1VZ9OjIlM/RfqjH0hGFS95nd6geNwpSbSpg4HxNmfltQ6GpoqclQXX0QdBO+q93sn33JjFPEhYuLvQcoea7Tl0zRY0AGQ9r7562QFlWqMmB+9YXcsZu2OZSk7t5a39jral0jEuEeJB56kb5ZUqRA1DJI5En09/WUPLCYprdb")
    end
    
    it "should select a public ssh key using a dialog if there is more than one valid public ssh key" do 
      STDIN.stubs(:gets).returns("1")
      key = Railshoster::Utilities.select_public_ssh_key(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "fake_dot_ssh", "2_valid_keys"), :verbose => false)
      key[:format].size.should > 1
    end
  end  
end