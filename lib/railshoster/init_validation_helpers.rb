module Railshoster
  module InitValidationHelpers
    
    UNSUPPORTED_DATABASE_GEMS   = %w(pq sqlite sqlite2 sqlite3)
    SUPPORTED_DATABASE_GEMS     = %w(mysql mysql2)
    
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
      gemfilelock_filepath = File.join(@project_dir, "Gemfile.lock")

      unless File.exists?(gemfilelock_filepath) then
        puts "\nWarning: Can't find Gemfile.lock. Are you using bundler? Try to perform bundle install AND/OR bundle update to create a Gemfile.lock. You will need it in order to deploy your app."  
        raise("Abortet. No Gemfile.lock found.")
      end
      gemfilelock_filepath
    end
    
    def check_gemfile_lock_db_dependencies(path_to_gemfilelock)
      gemfilelock = File.open(path_to_gemfilelock).read
      p = Bundler::LockfileParser.new(gemfilelock)
      
      found_supported_db_gems     = []
      found_unsupported_db_gems   = []
      
      p.dependencies.each do |dependency|
        found_supported_db_gems << dependency if SUPPORTED_DATABASE_GEMS.include?(dependency.name)
        found_unsupported_db_gems << dependency if UNSUPPORTED_DATABASE_GEMS.include?(dependency.name)
      end
      
      unless found_unsupported_db_gems.empty? then
        puts "Attention: You are using unsupported database gems. This might cause problems: #{found_unsupported_db_gems.inspect}"
      end

      if found_supported_db_gems.size == 1 then
        puts "Everything is fine. You are using: #{found_supported_db_gems.first.name}"

      elsif found_supported_db_gems.size > 1 then
        puts "You are using more than one supported database gem. Hence I cannot uniquely identify the gem your app depends on. Please change your Gemfile and perform bundle update to update your Gemfile.lock file."  
        raise("Abortet. Ambigious database gem information.")
      else
        raise("Abortet. Haven't found a supported database gem. Please consider to use mysql2.")
      end
      found_supported_db_gems.first
    end
    
    def check_os
      if OS.windows? then
        puts "\nWarning: This software requires a Unix/Linux/BSD OS. Do you really want to proceed?"
        decision = STDIN.gets.chomp
        unless %w(y Y).include?(decision) then
          raise("Initialization aborted. Bad operating system.")
        end              
      end
    end        
  end
end