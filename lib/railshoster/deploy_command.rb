module Railshoster
  
  # This action class helps to setup a new rails applicaton
  class DeployCommand < Command
    
    def initialize(project_dir)
      super(project_dir)
    end
    
    def deploy
      if capfile_exists? then
        system("cap deploy")
      else
        puts "\nDeployment abortet!\nYou haven't initialized your application, yet." 
        puts "Please use the 'railshoster init' command as described in your account information mail you have received from RailsHoster.com and try again.\n\n"
      end
    end
  end
end