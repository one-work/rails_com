require 'generators/rails/jbuilder_generator'

module Rails
  module Generators
    class JbuilderGenerator
      source_root File.expand_path('templates/jbuilder', __dir__)

      def copy_view_files
        ['index', '_show'].each do |view|
          filename = filename_with_extensions(view)
          template filename, File.join('app/views', controller_file_path, filename)
        end
        template filename_with_extensions('partial'), File.join('app/views', controller_file_path, filename_with_extensions("_#{singular_name}"))
      end

      def attributes_list(attributes = attributes_names)
        attributes.map { |a| ":#{a}"}.join(",\n" + ' '*14)
      end

    end
  end
end
