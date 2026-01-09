# frozen_string_literal: true

module RailsCom::ActiveRecord
  module ExtendFixture

    def yaml_files
      Dir["#{@path}{.yml,/{**,*}/*.yml}"].select { |f| ::File.file?(f) }
    end

    def comments
      yaml_files.each_with_object({}) do |file, comments|
        Psych::Pure.unsafe_load_file(file, comments: true).each do |x, v|
          comments[x] ||= {}
          v.each do |ik, iv|
            ic = iv.psych_node.comments.trailing.map(&:value).join(',')
            comments[x].merge! ik => ic.gsub(/^#\s*/, '') if ic.present?
          end
        end
      end
    end

  end
end

ActiveRecord::FixtureSet.include RailsCom::ActiveRecord::ExtendFixture
