require 'net/sftp'
require 'yaml'

module Railshoster
  module InitDatabaseHelpers
    
    # Currently pointless but for Postgres this will look like this {"pg" => "postgresql"}
    DB_GEM_TO_DB_ADAPTER = {"mysql" => "mysql", "mysql2" => "mysql2"}
    
    protected
    
    # Receive and update a database.yml via SFTP.
    def update_database_yml_db_adapters_via_ssh(host, sftp_session=nil, ssh_username = @app_hash["u"], path_to_dbyml = @app_hash["remote_db_yml"])
      dbyml = ""
      
      sftp_session ||= Net::SFTP.start(host, ssh_username)
                     
      sftp_session.file.open(path_to_dbyml) do |file|
        dbyml = file.read
      end
      
      sftp_session.file.open(path_to_dbyml, "w+") do |file|
        file.write(update_database_yml_db_adapters_in_yml(dbyml))
      end
      
    end
    
    def get_path_to_dbyml
      
    end
    
    # Takes a yml string, replaces the db adapters and produces yml again.
    def update_database_yml_db_adapters_in_yml(dbyml_str)      
      dbyml = YAML.load(dbyml_str)      
      
      db_adapter = DB_GEM_TO_DB_ADAPTER[@app_hash["db_gem"].downcase]
      
      %w(production development).each do |env|
        dbyml[env]["adapter"] = db_adapter
      end   
      
      YAML.dump(dbyml)
    end    
    
    # Receive a database.yml via SFTP.
    def get_database_yml(host, ssh_username, path_to_dbyml)
      dbyml = ""
      Net::SFTP.start(host, ssh_username) do |sftp|                
        sftp.file.open(path_to_dbyml) do |file|
          dbyml = file.read
        end
      end
      dbyml
    end          
  end
end
