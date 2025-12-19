module RailsCom
  module FrameHelper

    def turbo_frame_tagged(id, src: nil, target: nil, **attributes, &block)
      if request.headers['Turbo-Frame'].blank? && block_given?
        capture(&block)
      else
        turbo_frame_tag(id, src: src, target: target, **attributes, &block)
      end
    end

  end
end
