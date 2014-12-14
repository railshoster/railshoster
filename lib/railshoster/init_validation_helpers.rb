
module Railshoster
  
  # == Assumptions
  # * +@project_dir+ is defined.
  module InitValidationHelpers
    
    protected
    
    def check_system_requirements
      check_os
    end
    
    def check_project_requirements
      #TOOD implement  
      # check_git
      
      check_gemfile_exists
      check_gemfile_lock_exists            
    end
    
    def check_gemfile_exists
      gemfile = File.join(@project_dir, "Gemfile")
      unless File.exists?(gemfile) then
        puts "\nWarning: Your project does not seem to have a Gemfile. Please ensure your are using bundler."
        raise("Initialization aborted. No Gemfile found.")
      end
    end
        
    def check_gemfile_lock_exists      
      unless File.exists?(gemfilelock_filepath) then
        puts "\nWarning: Can't find Gemfile.lock. Are you using bundler? Try to perform bundle install AND/OR bundle update to create a Gemfile.lock. You will need it in order to deploy your app."  
        raise("Abortet. No Gemfile.lock found.")
      end
      gemfilelock_filepath
    end
        
    def check_os
      os = RUBY_PLATFORM.downcase
      if os.include?("mswin") || os.include?("mingw") then
        puts "\nWarning: This software requires a Unix/Linux/BSD OS. Do you really want to proceed?"
        decision = STDIN.gets.chomp
        unless %w(y Y).include?(decision) then
          raise("Initialization aborted. Bad operating system.")
        end           
      end
    end        
  end
end