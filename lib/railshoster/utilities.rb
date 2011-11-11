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
    
    def self.find_public_ssh_keys(ssh_dir =  File.join(get_user_home, ".ssh"))                  
      files_in_ssh_dir = Dir.glob(File.join(ssh_dir, "*.pub"))
      
      ssh_keys = []
      
      files_in_ssh_dir.each do |filepath|
        filepathname = Pathname.new(filepath)
        
        begin
          ssh_keys << parse_public_ssh_key_file(filepathname)      
        rescue InvalidPublicSshKeyError => e
          puts "\tNotice: #{filepathname} is not a valid public ssh key: #{e.message}"
        end
      end
      ssh_keys
    end  
    
    def self.parse_public_ssh_key_file(path_to_key)
      key = File.open(path_to_key).read
      key_hash = parse_public_ssh_key(key)
      key_hash[:path] = path_to_key
      key_hash
    end
    
    def self.parse_public_ssh_key(key)
      format_identifier, key_data = key.split(" ")   
      raise InvalidPublicSshKeyError.new("Couldn't recognize both format_identifier and/or key_data. One is missing") unless(format_identifier && key_data)
      {:format => format_identifier.chomp, :key_data => key_data.chomp, :key => key.chomp}
    end
        
    def self.get_user_home
      homes = ["HOME", "HOMEPATH"]
      home_key = homes.detect { |h| ENV[h] != nil }
      ENV[home_key]
    end
  end
end