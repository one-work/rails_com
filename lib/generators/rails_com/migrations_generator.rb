# frozen_string_literal: true
# bin/rails g rails_com:migrations
require 'rails/generators/active_record/migration'

class RailsCom::MigrationsGenerator < Rails::Generators::Base
  include ActiveRecord::Generators::Migration
  source_root File.expand_path('templates', __dir__)
  attr_reader :tables

  def create_migration_file
    RailsCom::Models.db_tables_hash.each do |mig_paths, tables|
      next if tables.blank?

      @tables = tables
      Array(mig_paths).each do |mig_path|
        file_name = "smart_#{mig_path.delete_prefix('db/')}_#{file_index}"
        migration_template 'migration.rb', File.join(mig_path, "#{file_name}.rb")
      end
    end
  end

  def file_index
    ups = ActiveRecord::Base.connection_pool.migration_context.migrations_status.select do |status, version, name|
      status == 'up' && name.start_with?('Smart migrate ')
    end
    if ups.present?
      index = ups[-1][-1].delete_prefix 'Smart migrate '
      index.to_i + 1
    else
      1
    end
  end

end
