# frozen_string_literal: true
module Com
  module Model::BlobDefault
    extend ActiveSupport::Concern

    included do
      attribute :record_class, :string, comment: 'AR 类名，如 User'
      attribute :name, :string, comment: '名称, attach 名称，如：avatar'
      attribute :macro, :string

      has_one_attached :file

      after_commit :delete_default_cache, on: [:create, :destroy]
      after_update_commit :delete_default_cache
    end

    def delete_default_cache
      r = Rails.cache.delete('blob_default')
      logger.debug "Cache key blob_default delete: #{r}"
    end

    class_methods do
      def defaults
        Rails.cache.fetch('blob_default') do
          BlobDefault.includes(:file_attachment).map do |i|
            ["#{i.record_class}_#{i.name}", i.file_attachment&.blob_id]
          end.compact.to_h
        end
      end

      def cache_clear
        Rails.cache.delete('blob_default')
      end

      # todo clean logic
      def sync
        RailsCom::Models.attachments.each do |model, attaches|
          attaches.each do |name, macro|
            bd = self.find_or_initialize_by(record_class: model, name: name)
            bd.macro = macro
            bd.save
          end
        end
      end
    end

  end
end
