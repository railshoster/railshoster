module Railshoster
  
  # This action class helps to deploy a rails applicaton
  class DeployCommand < Command
    
    def deploy
      if_project_already_initialized do
        Railshoster::Capistrano::Executor.execute_capistrano_task("deploy")
      end
    end
  end
end