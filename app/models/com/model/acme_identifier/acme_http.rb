module Com
  module Model::AcmeIdentifier::AcmeHttp
    extend ActiveSupport::Concern

    def ensure_config
      file_path = Rails.root.join('public/challenge', file_name)
      return true if file_path.file? && file_path.read == file_content

      file_path.dirname.exist? || file_path.dirname.mkpath
      File.open(file_path, 'w') do |f|
        f.write file_content
      end
      file_path.read == file_content
    end

    def auto_verify
      ensure_config
      authorization.http.request_validation
    rescue Acme::Client::Error::BadNonce
      retry
    ensure
      authorization.reload && self.update(status: authorization.status)
      #auto_verify if authorization.status == 'pending'
    end

  end
end
