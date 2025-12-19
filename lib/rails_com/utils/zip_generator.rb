# frozen_string_literal: true

require 'zip'

module ZipGenerator
  extend self

  def involve(input_dir = Rails.root.join('tmp', 'zip'), out_name = 'xx.zip')
    input_dir.exist? || input_dir.mkdir
    output_file = input_dir.join(out_name)

    ::Zip::File.open(output_file, create: true) do |zipfile|
      recursively_write(input_dir, zipfile, input_dir)
    end

    output_file
  end

  def recursively_write(disk_file_path, zipfile, input_dir)
    if File.directory? disk_file_path
      disk_file_path.children.each do |file_path|
        recursively_write(file_path, zipfile, input_dir)
      end
    else
      unless disk_file_path.basename.to_s == '.DS_Store'
        zipfile.add(disk_file_path.relative_path_from(input_dir).to_s, disk_file_path)
      end
    end
  end

end