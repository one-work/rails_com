require 'acme-client'
module Com
  module Model::AcmeOrder
    extend ActiveSupport::Concern

    included do
      attribute :orderid, :string
      attribute :url, :string
      attribute :issued_at, :datetime
      attribute :expire_at, :datetime, comment: '过期时间'
      if connection.adapter_name == 'PostgreSQL'
        attribute :identifiers, :string, array: true, default: []
      else
        attribute :identifiers, :json, default: []
      end
      attribute :sync_host, :string
      attribute :sync_path, :string

      enum :status, {
        pending: 'pending',
        ready: 'ready',
        valid: 'valid',
        invalid: 'invalid'
      }, prefix: true

      belongs_to :acme_account
      has_one :ssh_key, primary_key: :sync_host, foreign_key: :host

      has_many :acme_identifiers, dependent: :delete_all
      accepts_nested_attributes_for :acme_identifiers

      if ActiveStorage::Blob.services.instance_values.dig('configurations', :acme)
        has_one_attached :private_pem, service: :acme
        has_one_attached :cert_key, service: :acme
      else
        has_one_attached :private_pem
        has_one_attached :cert_key
      end

      after_update_commit :renew_before_expired, if: -> { saved_change_to_issued_at? && issued_at.present? }
      after_create_commit :get_order_later
    end

    def get_order_later
      AcmeOrderJob.perform_later(self)
    end

    # status: pending
    def order(renewal = false)
      if defined?(@order) && !renewal
        return @order
      end

      if !renewal && url
        begin
          @order = acme_account.client.order(url: url)
        rescue Acme::Client::Error::BadNonce
          retry
        rescue Acme::Client::Error::NotFound => e
          @order = renew_order
        end
      else
        @order = renew_order
      end

      @order
    end

    # x
    def renew_order
      r = acme_account.client.new_order(identifiers: identifiers)
    rescue Acme::Client::Error::BadNonce
      retry
    else
      self.orderid = r.to_h[:url].split('/')[-1]
      self.assign_attributes r.to_h.slice(:status, :url)
      self.set_authorizations!
      self.save!
      r
    end

    def get_cert(tries = 2)
      case order.status
      when 'invalid'
        order(true)
        get_cert
      when 'pending'
        set_authorizations!
        if all_verified?
          acme_identifiers.map(&:auto_verify).all?(true) && order.reload
        else
          AcmeOrderJob.set(wait: 60.seconds).perform_later(self)
          return
        end
        get_cert
      when 'ready'
        finalize
        get_cert
      when 'valid'
        cert # order.certificate_url.present?
      end
    rescue
      retry unless (tries -= 1).zero?
    end

    def set_authorizations!
      order.authorizations.each do |auth|
        ident = acme_identifiers.find_or_initialize_by(domain: auth.domain, wildcard: auth.wildcard)
        dns = auth.dns
        http = auth.http
        if dns
          ident.type = 'Com::AcmeDns'
          ident.record_name = dns.record_name
          ident.record_content = dns.record_content
        elsif http
          ident.type = 'Com::AcmeHttp'
          ident.file_name = http.filename
          ident.file_content = http.file_content
        end
        ident.url = auth.url
        ident.status = auth.status
        ident.save
      end
      ensure_config
    end

    def all_verified?
      acme_identifiers.all? { |i| i.verify? }
    end

    def ensure_config
      acme_identifiers.group_by(&:domain_root).map do |domain, owned_identifiers|
        acme_domain = AcmeDomain.find_by(domain: domain)
        next unless acme_domain
        rr = owned_identifiers.each_with_object({}) do |i, h|
          if h.key? i.rr
            h[i.rr] << i.record_content
          else
            h.merge! i.rr => [i.record_content]
          end
        end
        acme_domain.client.ensure_acme rr
      end
    end

    def identifiers_string
      identifiers.first.delete_prefix '*.'
    end

    def common_name
      identifiers.first
    end

    def csr
      return @csr if defined? @csr
      @csr = Acme::Client::CertificateRequest.new(
        names: identifiers,
        subject: {
          common_name: common_name,
          organization_name: '有个想法武汉软件咨询有限公司',
          organizational_unit: 'Work Design 工作设计'
        }
      )
      Tempfile.open do |file|
        file.binmode
        file.write @csr.private_key.to_pem
        file.rewind
        self.private_pem.attach io: file, filename: "#{identifiers_string}.key"
      end
      @csr
    end

    # status: valid
    def finalize
      order.finalize(csr: csr)
    rescue Acme::Client::Error::BadNonce
      retry
    ensure
      self.status = order.status
      self.save
    end

    def cert
      begin
        r = order.certificate(force_chain: 'DST Root CA X3')
      rescue Acme::Client::Error::ForcedChainNotFound
        r = order.certificate
      rescue Acme::Client::Error::BadNonce
        retry
      end

      if r
        file = Tempfile.new
        file.binmode
        file.write r
        file.rewind
        self.issued_at = Time.current
        self.status = order.status
        self.cert_key.attach io: file, filename: "#{identifiers_string}.pem"
        self.save
      end
      r
    end

    def sync_cert_to_host
      return unless ssh_key

      Net::SCP.start(sync_host, ssh_key.ssh_user, key_data: [ssh_key.private_key], keys_only: true, non_interactive: true) do |scp|
        scp.session.exec! "mkdir -p #{sync_path}"

        private_pem.blob.open do |file|
          scp.upload! file.path, "#{sync_path.delete_suffix('/')}/#{private_pem.blob.filename.to_s}"
        end

        cert_key.blob.open do |file|
          scp.upload! file.path, "#{sync_path.delete_suffix('/')}/#{cert_key.blob.filename.to_s}"
        end
      end
    end

    def nginx_reload
      return unless ssh_key

      Net::SCP.start(sync_host, ssh_key.ssh_user, key_data: [ssh_key.private_key], keys_only: true, non_interactive: true) do |scp|
        scp.session.exec! 'sudo nginx -s reload'
      end
    end

    def renew_before_expired
      AcmeJob.set(wait_until: issued_at + 2.months).perform_later(self)
    end

  end
end
