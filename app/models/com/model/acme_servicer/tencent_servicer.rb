begin
  require 'tencentcloud-sdk-dnspod'
rescue LoadError
end
module Com
  module Model::AcmeServicer::TencentServicer
    extend ActiveSupport::Concern

    def client
      return @client if defined? @client
      cre = TencentCloud::Common::Credential.new(key, secret)
      @client = TencentCloud::Dnspod::V20210323::Client.new(cre, 'ap-guangzhou')
    end

    def records
      request = TencentCloud::Dnspod::V20210323::DescribeRecordListRequest.new
      request.Domain = domain
      r = client.DescribeRecordList(request)
      r.RecordList
    end

    def ensure_acme(values_hash)
      results = records

      values_hash.each do |key, values|
        results.select do |i|
          if i.Name == key && values.exclude?(i.Value)
            delete(i.RecordId)
          end
        end

        values.each do |value|
          exist = results.find { |i| i.Name == key && i.Value == value }
          unless exist
            add_acme_record(key, value)
          end
        end
      end
    end

    def delete(id)
      request = TencentCloud::Dnspod::V20210323::DeleteRecordRequest.new(domain, id)
      client.DeleteRecord(request)
    end

    def add_acme_record(key, value)
      request = TencentCloud::Dnspod::V20210323::CreateRecordRequest.new(
        domain,
        'TXT',
        '默认',
        value,
        nil,
        key
      )
      client.CreateRecord(request)
    end

  end
end
