# frozen_string_literal: true

require 'httpx'
module ActiveStorage
  class Attached

    def url_sync(url, **options)
      filename = File.basename URI(url).path
      file = UrlUtil.file_from_url(url)

      if options.present?
        variation = ActiveStorage::Variation.new(options)
        output = variation.send(:transformer).send(:process, file, format: :jpg)
        self.attach io: output, filename: filename
        output
      else
        self.attach io: file, filename: filename
        file
      end
    end

    class One

      def variant(transformations)
        if attachment&.variable?
          attachment.variant(transformations)
        else
          self
        end
      end

    end
  end

end
