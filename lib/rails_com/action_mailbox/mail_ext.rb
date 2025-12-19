module RailsCom::ActionMailbox
  module MailExt

    def from
      r = super
      if r.is_a?(String)
        r.encode('utf-8', replace: '')
      elsif r.is_a?(Array)
        r.map { |i| i.encode('utf-8', replace: '') }
      else
        super
      end
    end

    def to
      r = super
      if r.is_a?(String)
        r.encode('utf-8', replace: '')
      elsif r.is_a?(Array)
        r.map { |i| i.encode('utf-8', replace: '') }
      else
        super
      end
    end

    def subject
      super.encode('utf-8', replace: '')
    end

    def parsed_body

    end

  end
end

require 'mail'
Mail::Message.prepend RailsCom::ActionMailbox::MailExt
