begin
  require 'aliyunsdkcore'
rescue LoadError
end
module Com
  module Model::AcmeServicer::AliServicer
    extend ActiveSupport::Concern

    def client
      return @client if defined? @client
      @client = RPCClient.new(
        endpoint: 'https://alidns.cn-hangzhou.aliyuncs.com',
        api_version: '2015-01-09',
        access_key_id: key,
        access_key_secret: secret
      )
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

    def ensure_acme(values_hash)
      results = records.dig('DomainRecords', 'Record')

      values_hash.each do |key, values|
        results.select do |i|
          if i['RR'] == key && values.exclude?(i['Value'])
            delete(i['RecordId'])
          end
        end

        values.each do |value|
          exist = results.find { |i| i['RR'] == key && i['Value'] == value }
          unless exist
            add_acme_record(key, value)
          end
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

    def add_acme_record(key, value)
      body = {
        action: 'AddDomainRecord'
      }
      body.merge! params: {
        DomainName: domain,
        Type: 'TXT',
        RR: key,
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
