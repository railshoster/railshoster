require 'base64'
require 'json'
require 'git'
require 'fileutils'
require 'net/sftp'
require 'bundler'

require File.expand_path(File.join(File.dirname(__FILE__), '/capistrano/config'))
require File.expand_path(File.join(File.dirname(__FILE__), '/init_ssh_helpers'))
require File.expand_path(File.join(File.dirname(__FILE__), '/init_capistrano_helpers'))
require File.expand_path(File.join(File.dirname(__FILE__), '/init_validation_helpers'))
require File.expand_path(File.join(File.dirname(__FILE__), '/init_gem_helpers'))

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
    
    def initialize(project_dir, application_hash_as_json_string)
      super(project_dir)    
      @application_hash_as_json_string = application_hash_as_json_string
    end
    
    #### Instance Methods
    def start
      check_system_requirements
      check_project_requirements      
      @app_hash = parse_application_json_hash(@application_hash_as_json_string)
      run_by_application_hash
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
    
    def run_by_application_hash      
      
      # e.g. mysql2
      @app_hash["db_gem"] = get_db_gem
            
      # Extract GIT URL from project and add it to the app_hash
      git_url = get_git_remote_url_from_git_config          
      @app_hash["git"] = git_url

      #TODO Add connection test -> If there's already access -> no need to do this
      selected_key = Railshoster::Utilities.select_public_ssh_key  
      @app_hash["public_ssh_key"] = Pathname.new(selected_key[:path]).basename.to_s.gsub(".pub", "")
          
      create_remote_authorized_key_file_from_app_hash(@app_hash, selected_key)      
      deployrb_str = create_deployrb(@app_hash)      
      write_deploy_rb(deployrb_str)
      capify_project
      success_message
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
    end
      
    def success_message
      puts "Your application has been successfully initialized."
      puts "\n\tYou can now use 'railshoster deploy' to deploy your app.\n\n"
      puts "Alternatively, you can use capistrano commands such as 'cap deploy' and 'cap shell'."
    end
  end
end