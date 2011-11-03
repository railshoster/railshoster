module RailsHoster
  
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
  end
end
