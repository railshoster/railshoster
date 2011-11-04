require 'fileutils'

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
  end
end