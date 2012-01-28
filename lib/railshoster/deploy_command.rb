module Railshoster
  
  # This action class helps to deploy a rails applicaton
  class DeployCommand < Command
    
    def initialize(project_dir)
      super(project_dir)
    end
    
    def deploy
      if_project_already_initialized do
        system("cap deploy")
      end
    end
    
    def deploy_setup
      if_project_already_initialized do
        system("cap deploy:setup")
      end
    end
    
    def deploy_cold
      if_project_already_initialized do
        system("cap deploy:cold")
      end
    end
  end
end