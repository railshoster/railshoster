require 'fileutils'
require 'etc'
require 'pathname'

module Railshoster
  class Utilities
    
    # Creates a backup of a file.
    # Since this is a recursive method you'll never loose a file. it also creates backups of backups of ...
    # == Examples
    # myfile -> myfile.bak
    # if there is already a myfile.bak:
    # myfile.bak -> myfile.bak.bak
    # myfile -> myfile.bak
    # ...
    def self.backup_file(path)
      backup_path = path + ".bak"
            
      if File.exists?(backup_path) then
        # There is already a backup, so we need to backup the backup first.
        backup_file(backup_path)
      end
      
      FileUtils.cp(path, backup_path)      
    end
    
    def self.find_public_ssh_keys                  
      user = Etc.getlogin  
      home = get_user_home
      ssh_dir = File.join(home, ".ssh", "*.pub")
      files_in_ssh_dir = Dir.glob(ssh_dir)
      files_in_ssh_dir.each do |filepath|
        filepathname = Pathname.new(filepath)
        puts filepathname.basename.to_s
      end
    end
    
    # Checks whether the given key is valid to be used in a authorized_keys file..
    def self.verify_public_ssh_key(key)
      format_identifier, key_data = key.split(" ")
      raise InvalidPublicSshKeyError.new("Couldn't recognize both format_identifier and/or key_data. One is missing") unless(format_identifier && key_data)
      
    end
    
    def self.get_user_home
      homes = ["HOME", "HOMEPATH"]
      home_key = homes.detect { |h| ENV[h] != nil }
      ENV[home_key]
    end
  end
end