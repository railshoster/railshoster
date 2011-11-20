module Railshoster
  module InitCapistranoHelpers
    
    protected
    
    def create_deployrb(app_hash)
      deployrb_str = ""
      
      # Choose the further process depending on the application type by applying a strategy pattern.
      case app_hash["t"].to_sym
        when :h, :v
          # Shared Hosting Deployments
          deployrb_str = Railshoster::Capistrano::Config.render_deploy_rb_to_s(app_hash)        
        else
          raise UnsupportedApplicationTypeError.new
      end
    end    
    
    def write_deploy_rb(deployrb_str)
      deployrb_basepath = File.join(@project_dir, "config")
      FileUtils.mkdir_p(deployrb_basepath)
      
      deployrb_path = File.join(deployrb_basepath, "deploy.rb")
      Railshoster::Utilities.backup_file(deployrb_path) if File.exists?(deployrb_path)
      
      File.open(deployrb_path, "w+") { |f| f << deployrb_str }
    end      
    
    def capify_project      
      puts "\n\tWarning: You are initializing a project with an existing Capfile.\n" if capfile_exists?
      successful = system("capify #{@project_dir}")
      raise CapifyProjectFailedError.new("Couldn't capify project at #{@project_dir}") unless successful
    end
  end
end