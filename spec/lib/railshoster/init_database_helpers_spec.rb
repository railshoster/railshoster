require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")


class MyInitDatabaseHelpersTestClass
  include Railshoster::InitDatabaseHelpers  
  
  def initialize
    @app_hash = {"t" => "v", "u" => "rails1", "a" => "rails1", "aid" => 1, "h" => "server1717.railsvserver.de", "p" => "xxx", "db_gem" => "mysql2"}
  end
end

describe Railshoster::InitDatabaseHelpers do
  describe "#Database.yml" do
    before do
      @my = MyInitDatabaseHelpersTestClass.new
    end
    
    it "should receive a database.yml" do
      pending("mock sftp")
      @my.send(:get_database_yml, "server1717.railsvserver.de", "rails1", "/var/www/rails1/shared/config/database.yml")
    end
    
    it "should read and update a remote database.yml" do
      pending("mock sftp")
      @my.send(:update_database_yml_db_adapters_via_ssh, "server1717.railsvserver.de", "rails1", "/var/www/rails1/shared/config/database.yml")
    end
    
    it "should updatea a database.yml" do
      mysql_database_yml = File.open(File.join(File.dirname(__FILE__), "..", "..", "fakefs", "database_yml", "database.mysql.yml")).read
      @my.send(:update_database_yml_db_adapters_in_yml, mysql_database_yml).should eql("--- \nproduction: \n  username: rails1\n  adapter: mysql2\n  database: rails1\n  password: Nut4KBvOqHJ5\n  socket: /var/run/mysqld/mysqld.sock\ndevelopment: \n  username: rails1\n  adapter: mysql2\n  database: rails1_development\n  password: Nut4KBvOqHJ5\n  socket: /var/run/mysqld/mysqld.sock\n")
    end
  end
end