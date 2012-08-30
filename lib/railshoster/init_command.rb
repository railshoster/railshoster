require 'base64'
require 'json'
require 'git'
require 'fileutils'
require 'bundler'

require File.expand_path(File.join(File.dirname(__FILE__), '/capistrano/config'))
require File.expand_path(File.join(File.dirname(__FILE__), '/init_ssh_helpers'))
require File.expand_path(File.join(File.dirname(__FILE__), '/init_capistrano_helpers'))
require File.expand_path(File.join(File.dirname(__FILE__), '/init_validation_helpers'))
require File.expand_path(File.join(File.dirname(__FILE__), '/init_gem_helpers'))
require File.expand_path(File.join(File.dirname(__FILE__), '/init_database_helpers'))

module Railshoster
  
  # This action class helps to setup a new rails applicaton
  #
  # == Design Contraints
  # * The workflow of this class should be easy to read. Hence helper methods are sourced out to helper modules.
  # * All modifications of the @app_hash must be done within this file not in a helper module. This helps to easily grasp the app_hash structure with all changed made to it.
  class InitCommand < Command        
    
    include Railshoster::InitSshHelpers
    include Railshoster::InitCapistranoHelpers
    include Railshoster::InitGemHelpers
    include Railshoster::InitValidationHelpers  
    include Railshoster::InitDatabaseHelpers    
    
    def initialize(project_dir, application_hash_as_json_string)
      super(project_dir)    
      @application_hash_as_json_string = application_hash_as_json_string
    end
    
    #### Instance Methods
    def start
      check_system_requirements
      check_project_requirements      
      @app_hash = parse_application_json_hash(@application_hash_as_json_string)
      expand_app_hash_product_specifically
      process_application_hash
    end
    
    #### Static
    
    def self.run_by_application_token(project_dir, application_token) 
      decoded_token = decode_token(application_token)
      
      begin
        new(project_dir, decoded_token).start
      rescue BadApplicationJSONHashError => e
        msg = "Please verify your application_token. It did not decode to a valid application hash.\n" +
          "This is how your application token looked like:\n\n#{application_token.inspect}\n\n" +
          "Please compare your application token char by char with your account information mail and try again!\n" +
          "Here is what the application hash parser said:\n\n"
        raise BadApplicationTokenError.new(msg + e.message)
      end
    end
    
    #### Protected Instance Methods
    
    protected
    
    def process_application_hash
      expand_app_hash
      expand_app_hash_product_specifically
      # e.g. mysql2
      @app_hash["db_gem"] = get_db_gem.name
            
      # Extract GIT URL from project and add it to the app_hash
      git_url = get_git_remote_url_from_git_config          
      @app_hash["git"] = git_url

      sftp_session = try_to_get_a_sftp_session_without_password(@app_hash["h"].first, @app_hash["u"])
      
      if sftp_session == nil
        selected_key = Railshoster::Utilities.select_public_ssh_key  
        @app_hash["public_ssh_key"] = Pathname.new(selected_key[:path]).basename.to_s.gsub(".pub", "")
        create_remote_authorized_key_file_from_app_hash(@app_hash, selected_key) 
      end     
    
      @app_hash["remote_db_yml"]  = "#{@app_hash["deploy_to"]}/shared/config/database.yml"

      @app_hash["h"].each do |host|
        update_database_yml_db_adapters_via_ssh(host, sftp_session)
      end
      
      
      deployrb_str = create_deployrb(@app_hash)     
      write_deploy_rb(deployrb_str)
      capify_project
      success_message
    end

    def expand_app_hash

      # Turn "h" in to an array unless it's not already one.
      @app_hash["h"] = [ @app_hash["h"] ] unless @app_hash["h"].is_a?(Array)
    end
    
    # Add values ot app_hash specific to the given product type.
    def expand_app_hash_product_specifically
      case @app_hash["t"].to_sym
        when :h
          @app_hash["deploy_to"]      = "/home/#{@app_hash['u']}/#{@app_hash['a']}"
          @app_hash["app_url"]        = "http://#{@app_hash['u']}-#{@app_hash['aid']}.#{@app_hash['h']}"
        when :v
          @app_hash["deploy_to"]      = "/var/www/#{@app_hash['a']}"
          @app_hash["app_url"]        = "http://#{@app_hash['a']}.#{@app_hash['h']}"
        when :pc 
          @app_hash["deploy_to"]      = "/var/www/#{@app_hash['a']}"
          @app_hash["app_url"]        = "http://#{@app_hash['au']}"
        else
          raise UnsupportedApplicationTypeError.new
      end
    end
        
    # Decodoes token to get the JSON hash back.
    # gQkUSMakKRPhm0EIaer => {"key":"value"}
    def self.decode_token(token)      
      Base64.decode64(token)
    end
    
    def parse_application_json_hash(app_hash_as_json_string)
      begin
        ruby_app_hash = ::JSON.parse(app_hash_as_json_string)      
      rescue JSON::ParserError => e      
        msg = "The application hash you have passed is malformed. It could not be parsed as regular JSON. It looked like this:\n\n #{app_hash_as_json_string.inspect}\n"  
        raise BadApplicationJSONHashError.new(msg + "\nHere is what the JSON parse said:\n\n" + e.message)
      end
      ruby_app_hash
    end
      
    def success_message
      puts "Your application has been successfully initialized."
      puts "\n\tYou can now use 'railshoster deploy' to deploy your app.\n\n"
      puts "Alternatively, you can use capistrano commands such as 'cap deploy' and 'cap shell'."
    end
  end
end
