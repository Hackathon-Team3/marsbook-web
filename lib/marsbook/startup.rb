require "active_record"

module Marsbook
  class Startup

    def self.initialize
      connect
      create_table
    end


    private

    def self.connect
      ActiveRecord::Base.establish_connection(
          adapter:  "mysql",
          host:     ENV['RDS_ADDRESS'],
          port:     3306,
          username: ENV["RDS_USERNAME"],
          password: ENV["RDS_PASSWORD"],
          database: ENV['RDS_DATABASENAME']
      )
    end

    def self.create_table
      # break out early if 'projects' table already exists
      return if (ActiveRecord::Base.connection.table_exists? ('interesting_images'))

      ActiveRecord::Migration.class_eval do
        create_table :interesting_images do |t|
          t.string :url
          t.string :timestamp
        end
      end
    end
  end
end