module Railshoster
  
  # This action class helps to setup a new rails applicaton
  class Command
    
    def initialize(project_dir)      
      @project_dir = project_dir
      
      begin      
        @git = Git.open(project_dir)
      rescue ArgumentError => e
        raise PossiblyNotAGitRepoError.new(e)
      end
    end
    
    protected
    
    def capfile_exists?
      File.exists?(capfile_path)
    end
    
    def capfile_path 
      File.join(@project_dir, "Capfile")
    end
    
    def deployrb_exists?
      File.exists?(deployrb_path)
    end
    
    def deployrb_path
      File.join(@project_dir, "config", "deploy.rb")
    end
    
    def if_project_already_initialized(&block)
      if project_already_initialized? then
        yield
      else
        puts "\nCommand execution aborted!\nYou haven't initialized your application, yet." 
        puts "Please use the 'railshoster init' command and try again.\n\n"
      end
    end      
    
    def project_already_initialized?
      (capfile_exists? and deployrb_exists?)
    end
  end
end
