require 'erubis'

module Railshoster
  module Capistrano
    
    # Strategy to generate a capistrano config for a shared hosting
    class Config
      
      #### Static
      
      def self.render_deploy_rb_for_capistrano_3_to_s(application_hash)
        deployrb_template = File.read(File.join(File.dirname(__FILE__), "../../../templates/h/deploy_version_3.rb.erb"))
        eruby = Erubis::Eruby.new(deployrb_template)
        eruby.result(:app => application_hash)
      end

      def self.render_deploy_rb_for_capistrano_2_to_s(application_hash)
        deployrb_template = File.read(File.join(File.dirname(__FILE__), "../../../templates/h/deploy_version_2.rb.erb"))
        eruby = Erubis::Eruby.new(deployrb_template)
        eruby.result(:app => application_hash)
      end
    end
  end
end
