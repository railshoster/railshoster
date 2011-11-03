module Railshoster
  module Capistrano
    
    # Strategy to generate a capistrano config for a shared hosting
    class H
      
      def run(application_hash)
        puts "Please implement the strategy to prepare a shared hosting app. We need strategy dependent folders to store the capistrano templates."        
      end
      
      def self.run(application_hash)
        h = new
        h.run(application_hash)
      end
    end
  end
end