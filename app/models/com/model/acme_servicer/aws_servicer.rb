begin
  require 'aws-sdk-route53'
rescue LoadError
end
module Com
  module Model::AcmeServicer::AwsServicer

    def client
      return @client if defined? @client
      credentials = Aws::Credentials.new(key, secret)
      @client = Aws::Route53::Client.new(region: 'us-west-2', credentials: credentials)
    end

    def records
      body = {
        action: 'DescribeDomainRecords'
      }
      body.merge! params: {
        DomainName: domain
      }
      body.merge! opts: {
        method: 'POST',
        timeout: 15000
      }

      client.request(**body)
    end

    def ensure_acme(value)
      result = records.dig('DomainRecords', 'Record')
      if result
        rs = result.select { |i| i['RR'] == rr }
        rs.each do |r|
          delete(r['RecordId']) if r['Value'] != value
        end
        if rs.blank?
          add_acme_record(value)
        else
          rs[0]
        end
      end
    end

    def delete(id)
      body = { action: 'DeleteDomainRecord' }
      body.merge! params: {
        RecordId: id
      }
      body.merge! opts: {
        method: 'POST',
        timeout: 15000
      }

      client.request(**body)
    end

    def add_acme_record(value)
      body = {
        action: 'AddDomainRecord'
      }
      body.merge! params: {
        DomainName: domain,
        Type: 'TXT',
        RR: rr,
        value: value
      }
      body.merge! opts: {
        method: 'POST',
        timeout: 15000
      }

      client.request(**body)
    end

  end
end
