module Railshoster
  
  # This action class shows the default railshoster.com url of a project.
  class AppUrlCommand < Command
    
    def show
      if_project_already_initialized do
        system("cap railshoster:appurl")
      end
    end
  end
end