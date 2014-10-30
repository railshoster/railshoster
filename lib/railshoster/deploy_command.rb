module Railshoster
  
  # This action class helps to deploy a rails applicaton
  class DeployCommand < Command
    
    def initialize(project_dir)
      super(project_dir)
    end
    
    def deploy
      if_project_already_initialized do
        if capistrano_greater_than_2?
          system("cap production deploy")
        else
          system("cap deploy")
        end
      end
    end

    def deploy_setup
      if_project_already_initialized do
        if capistrano_greater_than_2?
          system("cap production deploy:setup")
        else
          system("cap deploy:setup")
        end
      end
    end

    def deploy_cold
      if_project_already_initialized do
        if capistrano_greater_than_2?
          system("cap production deploy:cold")
        else
          system("cap deploy:cold")
        end
      end
    end
  end
end
