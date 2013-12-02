require 'rails/generators/active_record'

module PaperclipDatabase
  module Generators
    class MigrationGenerator < ActiveRecord::Generators::Base
      desc "Create a migration to add database storage for the paperclip database storage. " +
           "run: rails generate paperclip_database:migration install"


      def self.source_root
        @source_root ||= File.expand_path('../templates', __FILE__)
      end

      def generate_migration
        migration_template "migration.rb.erb", "db/migrate/#{migration_file_name}"
      end


      protected

      def table_name
        'paperclip_database_files'
      end

      def migration_name
        "create_table_#{table_name}"
      end

      def migration_file_name
        "#{migration_name}.rb"
      end

      def migration_class_name
        migration_name.camelize
      end

    end
  end
end