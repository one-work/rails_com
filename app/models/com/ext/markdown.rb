module Com
  module Ext::Markdown
    extend ActiveSupport::Concern

    included do
      attribute :markdown, :string
      attribute :title, :string
      attribute :html, :string

      before_save :set_html, if: -> { markdown_changed? }
    end

    def document
      return @document if defined? @document
      @document = Kramdown::Document.new(
        markdown,
        input: 'GFM',
        syntax_highlighter_opts: {
          line_numbers: true,
          wrap: true
        }
      )
    end

    def converter
      return @converter if defined? @converter
      @converter = Kramdown::Converter::Html.send :new, document.root, document.options
    end

    def new_contents
      deal_links_and_images
      document.root.children
    end

    def deal_links_and_images
      links = document.root.group_elements(a: [], img: [])
      links[:a].each do |link|
        convert_link(link)
      end
      links[:img].each do |link|
        convert_img(link)
      end
    end

    def convert_img(link)
      unless link.attr['src'].start_with?('http', '//')
        link.attr['src'].prepend based_assets_path
      end
    end

    def convert_link(link)
      if link.attr['href'].start_with?('http', '//')
        link.attr['target'] = '_blank'
      elsif link.attr['href'].start_with?('/')
        link.attr['target'] = '_blank'
      end
    end

    def deal_h1_and_blank
      h1 = document_h1
      contents = document.root.children
      if h1
        contents.delete(h1)
      end
      while contents[0]&.type == :blank do
        contents.delete_at(0)
      end
    end

    def document_h1
      document.root.children.find { |i| i.type == :header && i.options[:level] == 1 }
    end

    def set_title
      h1 = document_h1
      if h1
        self.title = h1.options[:raw_text]
      end
    end

    def set_html
      self.deal_links_and_images
      self.deal_h1_and_blank
      self.html = document.to_html
      self.set_title
    end

  end
end
