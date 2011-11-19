require 'base64'
require 'json'
require 'git'
require 'fileutils'
require 'net/sftp'
require 'sane'

require File.expand_path(File.join(File.dirname(__FILE__), '/capistrano/config'))

module Railshoster
  
  # This action class helps to setup a new rails applicaton
  class InitCommand < Command        
    
    def run_by_application_token(application_token) 
      decoded_token = decode_token(application_token)
      
      begin
        run_by_application_hash(decoded_token)
      rescue BadApplicationJSONHashError => e
        msg = "Please verify your application_token. It did not decode to a valid application hash.\n" +
          "This is how your application token looked like:\n\n#{application_token.inspect}\n\n" +
          "Please compare your application token char by char with your account information mail and try again!\n" +
          "Here is what the application hash parser said:\n\n"
        raise BadApplicationTokenError.new(msg + e.message)
      end
    end
    
    def run_by_application_hash(application_hash_as_json_string)
      check_system_requirements
      check_project_requirements
      app_hash = parse_application_json_hash(application_hash_as_json_string)
      
      # Extract GIT URL from project and add it to the app_hash
      git_url = get_git_remote_url_from_git_config          
      app_hash["git"] = git_url

      #TODO Add connection test -> If there's already access -> no need to do this
      selected_key = Railshoster::Utilities.select_public_ssh_key  
      app_hash["public_ssh_key"] = Pathname.new(selected_key[:path]).basename.to_s.gsub(".pub", "")
          
      create_remote_authorized_key_file_from_app_hash(app_hash, selected_key)      
      deployrb_str = create_deployrb(app_hash)      
      write_deploy_rb(deployrb_str)
      capify_project
      success_message
    end
    
    protected
    
    def check_system_requirements
      check_os
    end
    
    def check_project_requirements
      #TOOD implement  
      # check_git
      
      check_gemfile
    end
    
    def check_gemfile
      gem_file = File.join(@project_dir, "Gemfile")
      unless File.exists?(gem_file) then
        puts "\nWarning: Your project does not seem to have a Gemfile. Please ensure your are using bundler."
        exit_now!("Initialization aborted. No Gemfile found.", -1)
      end
    end
    
    def check_os
      if OS.windows? then
        puts "\nWarning: This software requires a Unix/Linux/BSD OS. Do you really want to proceed?"
        decision = STDIN.gets.chomp
        unless %w(y Y).include?(decision) then
          exit_now!("Initialization aborted. Bad operating system.", -1)
        end              
      end
    end
    
    def create_remote_authorized_key_file_from_app_hash(app_hash, key)
      if app_hash["t"].eql?("h") then
        
        # For a hosting package the password is the deploy user's password
        create_remote_authorized_key_file(app_hash["h"], app_hash["u"], app_hash["p"], key)
      elsif app_hash["t"].eql?("v") then
        
        # For a vps the given password it the root user's password -> Register key for root user
        create_remote_authorized_key_file(app_hash["h"], "root", app_hash["p"], key)        
        
        # Also register the public key to enable key access to the deploy user
        # This means that the
        create_remote_authorized_key_file(app_hash["h"], "root", app_hash["p"], key, "/home/#{app_hash['u']}/.ssh", app_hash['u'])        
      else
        exit_now!("Initialization aborted. Invalid product type: #{app_hash['t']}.", -1)
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
    end     
    
    def create_deployrb(app_hash)
      deployrb_str = ""
      
      # Choose the further process depending on the application type by applying a strategy pattern.
      case app_hash["t"].to_sym
        when :h, :v
          # Shared Hosting Deployments
          deployrb_str = Railshoster::Capistrano::Config.render_deploy_rb_to_s(app_hash)        
        else
          raise UnsupportedApplicationTypeError.new
      end
    end    
    
    # Decodoes token to get the JSON hash back.
    # gQkUSMakKRPhm0EIaer => {"key":"value"}
    def decode_token(token)      
      Base64.decode64(token)
    end
    
    def parse_application_json_hash(app_hash_as_json_string)
      begin
        ruby_app_hash = ::JSON.parse(app_hash_as_json_string)      
      rescue JSON::ParserError => e      
        msg = "The application hash you have passed is malformed. It could not be parsed as regular JSON. It looked like this:\n\n #{app_hash_as_json_string.inspect}\n"  
        raise BadApplicationJSONHashError.new(msg + "\nHere is what the JSON parse said:\n\n" + e.message)
      end
    end
    
    def get_git_remote_url_from_git_config
      
      #TODO Error management: what if there is not remote url (local repo)?
      @git.config['remote.origin.url']
    end
    
    def write_deploy_rb(deployrb_str)
      deployrb_basepath = File.join(@project_dir, "config")
      FileUtils.mkdir_p(deployrb_basepath)
      
      deployrb_path = File.join(deployrb_basepath, "deploy.rb")
      Railshoster::Utilities.backup_file(deployrb_path) if File.exists?(deployrb_path)
      
      File.open(deployrb_path, "w+") { |f| f << deployrb_str }
    end      
    
    def capify_project      
      puts "\n\tWarning: You are initializing a project with an existing Capfile.\n" if capfile_exists?
      successful = system("capify #{@project_dir}")
      raise CapifyProjectFailedError.new("Couldn't capify project at #{@project_dir}") unless successful
    end
    
    def success_message
      puts "Your application has been successfully initialized."
      puts "\n\tYou can now use 'railshoster deploy' to deploy your app.\n\n"
      puts "Alternatively, you can use capistrano commands such as 'cap deploy' and 'cap shell'."
    end
  end
end