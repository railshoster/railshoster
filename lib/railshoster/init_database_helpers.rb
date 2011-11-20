require 'net/sftp'
require 'yaml'

module Railshoster
  module InitDatabaseHelpers
    
    # Currently pointless but for Postgres this will look like this {"pg" => "postgresql"}
    DB_GEM_TO_DB_ADAPTER = {"mysql" => "mysql", "mysql2" => "mysql2"}
    
    protected
    
    def update_database_yml_adapters(dbyml_str)      
      dbyml = YAML.load(dbyml_str)      
      db_adapter = DB_GEM_TO_DB_ADAPTER[@app_hash["db_gem"].downcase]
      
      %w(production development).each do |env|
        dbyml[env]["adapter"] = db_adapter
      end   
      
      YAML.dump(dbyml)
    end    
    
    # Receive a database.yml
    def get_database_yml(host, ssh_username, path_to_dbyml)
      Net::SFTP.start(host, ssh_username) do |sftp|                
        sftp.file.open(path_to_dbyml) do |file|
          dbyml = file.read
        end
      end
      dbyml
    end  
    
    # Receive and update a database.yml
    def update_database_yml_db_adapters(host, ssh_username, path_to_dbyml)
      dbyml = ""
      Net::SFTP.start(host, ssh_username) do |sftp|                
        sftp.file.open(path_to_dbyml) do |file|
          dbyml = file.read
        end
        sftp.file.open(path_to_dbyml, "w+") do |file|
          file.write(update_database_yml_adapters(dbyml))
        end
      end
    end
  end
end