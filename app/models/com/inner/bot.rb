module Com
  module Inner::Bot
    extend ActiveSupport::Concern

    included do
      attr_reader :content

      after_initialize :init_ivar
    end

    def init_ivar
      @content = ''
    end

    def add_column(title, content)
      @content << "**#{title}：**#{content}\n"
    end

    def add_paragraph(content)
      @content << "#{content}\n"
    end

    def add_section(header, paragraph, level: 3)
      @content << "#{'#' * level} #{header}\n"
      @content << "#{paragraph}\n"
    end

    def link_more(name, url)
      text = "\n[#{name}](#{url})"
      truncate_length = 4096 - text.bytesize

      @content = @content.truncate_bytes(truncate_length) + text
    end

  end
end
