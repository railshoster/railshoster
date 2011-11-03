require 'base64'
require 'json'
require 'git'
require 'fileutils'

module RailsHoster
  
  # This action class helps to setup a new rails applicaton
  class InitCommand
    
    def initialize(git_dir)
      begin      
        @git = Git.open(git_dir)
      rescue ArgumentError => e
        raise PossiblyNotAGitRepoError.new(e)
      end
    end
        
    def run_by_application_token(application_token) 
      decoded_token = decode_token(application_token)
      run_by_application_hash(decoded_token)
    end
    
    def run_by_application_hash(application_hash_as_json_string)
      app_hash = parse_application_json_hash(application_hash_as_json_string)
      
      git_url = get_git_remote_url_from_git_config          
      app_hash[:git] = git_url
      
      # Choose the further process depending on the application type by applying a strategy pattern.
      case app_hash["t"].to_sym
        when :h
          # Shared Hosting Deployments
          puts "Please implement the strategy to prepare a shared hosting app. We need strategy dependent folders to store the capistrano templates."
        # Later also support VPS Deployments
        # when :v
        else
          raise UnsupportedApplicationTypeError.new
      end
    end
    
    protected
    
    # Decodoes token to get the JSON hash back.
    # gQkUSMakKRPhm0EIaer => {"key":"value"}
    def decode_token(token)
      Base64.decode64(token)
    end
    
    def parse_application_json_hash(app_hash_as_json_string)
      ruby_app_hash = ::JSON.parse(app_hash_as_json_string)      
    end
    
    def get_git_remote_url_from_git_config
      
      #TODO Error management: what if there is not remote url (local repo)?
      @git.config('remote.origin.url')
    end
  end
  
  class PossiblyNotAGitRepoError < ArgumentError
  end
  
  class UnsupportedApplicationTypeError < ArgumentError
  end
end