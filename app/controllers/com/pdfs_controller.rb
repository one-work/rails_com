# frozen_string_literal: true
module Com
  class PdfsController < BaseController
    before_action :set_pdf, only: [:show, :png, :jpg]

    def show
      send_data @pdf.render, filename: 'cert_file.pdf', disposition: @disposition, type: 'application/pdf'
    end

    def png
      require 'vips'
      buffer = Vips::Image.pdfload_buffer @pdf.render

      send_data buffer.write_to_buffer('.png'), filename: 'cert_file.png', disposition: @disposition, type: 'image/png'
    end

    def jpg
      require 'vips'
      buffer = Vips::Image.pdfload_buffer @pdf.render

      send_data buffer.write_to_buffer('.jpg'), filename: 'cert_file.jpg', disposition: @disposition, type: 'image/jpg'
    end

    private
    def set_pdf
      @pdf_class = params[:id].constantize
      @pdf ||= @pdf_class.new(**pdf_params)
      @disposition = params[:disposition] || 'inline'
    end

    def pdf_params
      keys = @pdf_class.instance_method(:initialize).parameters.to_array_h.to_combine_h[:key]
      params.permit(*keys).to_h.symbolize_keys
    end

  end
end
