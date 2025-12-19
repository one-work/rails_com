module Com
  module Model::AcmeIdentifier::AcmeDns
    extend ActiveSupport::Concern

    def dns_host
      "#{record_name}.#{domain}"
    end

    def rr
      [record_name, *domain.split('.')[0...-2]].join('.')
    end

    def verify?
      dns_resolv = Resolv::DNS.open { |dns| dns.getresources(dns_host, Resolv::DNS::Resource::IN::TXT).map!(&:data) }
      logger.debug "\e[35m  DNS: #{dns_resolv}, Record: #{record_content}  \e[0m"
      dns_resolv.include?(record_content)
    end

    def auto_verify
      authorization.dns.request_validation
    rescue Acme::Client::Error::BadNonce
      retry
    ensure
      authorization.reload && self.update(status: authorization.status)
      status_valid?
    end

  end
end
