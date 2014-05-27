module Railshoster
  module InitCapistranoHelpers


    protected

    def create_deployrb(app_hash)
      deployrb_str = ""
      deployrb_str = if capistrano_greater_than_2?
                       Railshoster::Capistrano::Config.render_deploy_rb_for_capistrano_3_to_s(app_hash)
                     else
                       Railshoster::Capistrano::Config.render_deploy_rb_for_capistrano_2_to_s(app_hash)
                     end
    end    

    def write_deploy_rb(deployrb_str)
      deployrb_basepath = File.join(@project_dir, "config")
      FileUtils.mkdir_p(deployrb_basepath)

      deployrb_path = if capistrano_greater_than_2?
                        File.join(deployrb_basepath, "deploy/production.rb")
                      else
                        File.join(deployrb_basepath, "deploy.rb")
                      end
      Railshoster::Utilities.backup_file(deployrb_path) if File.exists?(deployrb_path)

      File.open(deployrb_path, "w+") { |f| f << deployrb_str }
    end      

    def capify_project      
      puts "\n\tWarning: You are initializing a project with an existing Capfile.\n" if capfile_exists?
      successful = if capistrano_greater_than_2?
                     puts "\tCapistrano greater than 2 detected"
                     system("cd #{@project_dir} && cap install")
                   else
                     system("capify #{@project_dir}")
                   end
      raise CapifyProjectFailedError.new("Couldn't capify project at #{@project_dir}") unless successful
    end
  end
end
