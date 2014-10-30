module Railshoster
  module GeneralCapistranoHelpers

    def installed_capistrano_version
      require 'capistrano/version'
      if ::Capistrano.const_defined?('VERSION') 
        return ::Capistrano::VERSION
      elsif ::Capistrano.const_defined?('Version')
        return ::Capistrano::Version.to_s
      end
    end

    def capistrano_greater_than_2?
      return installed_capistrano_version >= '3.0.0'
    end

  end
end
