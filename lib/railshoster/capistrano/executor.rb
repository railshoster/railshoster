require 'rubygems'
gem 'capistrano'
require 'capistrano/cli'

module Railshoster
  module Capistrano
    class Executor
      
      # Executes the given capistrano task.
      def self.execute_capistrano_task(task = "deploy")
          cap = ::Capistrano::CLI.parse([task])
          cap_config = cap.execute!
        end
    end
  end
end