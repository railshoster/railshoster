require 'net/sftp'
require 'highline/import'

module Railshoster
  module InitSshHelpers
    
    protected
    
    def create_remote_authorized_key_file_from_app_hash(app_hash, key)
      if app_hash["t"].eql?("h") then
        
        # For a hosting package the password is the deploy user's password
        create_remote_authorized_key_file(app_hash["h"].first, app_hash["u"], app_hash["p"], key)
      elsif app_hash["t"].eql?("v") || app_hash["t"].eql?("m") then
        
        # For a vps the given password it the root user's password -> Register key for root user
        create_remote_authorized_key_file(app_hash["h"].first, "root", app_hash["p"], key)        
        
        # Also register the public key to enable key access to the deploy user  
        create_remote_authorized_key_file(app_hash["h"].first, "root", app_hash["p"], key, "/home/#{app_hash['u']}/.ssh", app_hash['u'])        
      elsif app_hash["t"].eql?("pc") then

        # For a private cloud setup we act on several vps
        # but in this case the app_hash stores the deploy user's password not the root password as for vps setups
        app_hash["h"].each do |host|
           create_remote_authorized_key_file(host, app_hash["u"], app_hash["p"], key)
        end
      else
        raise("Initialization aborted. Invalid product type: #{app_hash['t']}.")
      end
    end

    # Creates a remote authorized keys file for the given public key
    #
    # === Parameters
    # +host+:: SSH host to connect to
    # +password+:: SSH password
    # +key+:: Public key hash. Have a look at +Railshoster::Utilities.select_public_ssh_key+ for more details about the key structure.
    # +remote_dot_ssh_path+:: Remote path to the user's .ssh path. Usually this is relative to the ssh-users's home path. Use absolute path names to avoid that.
    # +target_username+:: Optional. If this parameter is set .ssh directory and the authorized_keys file will be assegned to the user with the given username.
    def create_remote_authorized_key_file(host, ssh_username, password, key, remote_dot_ssh_path = ".ssh", target_username = nil)

      remote_authorized_keys_path = remote_dot_ssh_path + "/authorized_keys"
      
      begin 
  
        Net::SFTP.start(host, ssh_username, :password => password) do |sftp|                
          #TODO Smarter way to determine home directory
          stats = sftp.stat!("/home/#{target_username}") if target_username
  
          begin
            sftp.mkdir!(remote_dot_ssh_path)
            sftp.setstat(remote_dot_ssh_path, :uid => stats.uid, :gid => stats.gid) if target_username
          rescue Net::SFTP::StatusException => e
            # Most likely the .ssh folder already exists raise again if not.
            raise e unless e.code == 4
          end
          sftp.upload!(key[:path].to_s, remote_authorized_keys_path)
          sftp.setstat(remote_authorized_keys_path, :uid => stats.uid, :gid => stats.gid) if target_username 
        end 
      rescue Net::SSH::AuthenticationFailed => e
        create_remote_authorized_key_file(host, ssh_username, ask_for_ssh_password(ssh_username), key, remote_dot_ssh_path, target_username)
      end
        
    end
    
    def try_to_get_a_sftp_session_without_password(host, user)
    
      begin 
        return Net::SFTP.start(host, user)
      rescue Net::SSH::AuthenticationFailed => e
        return nil
      end
      
    end
    
    def ask_for_ssh_password(user)
      ask("Enter ssh password for user #{user}: ") { |q| q.echo = false }
    end
  end
end
