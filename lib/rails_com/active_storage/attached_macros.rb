# frozen_string_literal: true

module RailsCom::AttachedOne

  def attachment
    if super
      return super
    elsif defined?(@attachment)
      return @attachment
    end

    id = Com::BlobDefault.defaults["#{record.class.name}_#{name}"]
    if id
      begin
        @attachment = ActiveStorage::Attachment.new(record: record, name: name, blob: ActiveStorage::Blob.find(id))
      rescue ActiveRecord::RecordNotFound => e
        Rails.cache.delete('blob_default/default')
        retry
      end
    end
  end

  def copy(from, from_name)
    from_attachment = from.send "#{from_name}_attachment"
    record.send "create_#{name}_attachment", blob_id: from_attachment.blob_id if from_attachment
  end

end

ActiveSupport.on_load(:active_storage_record) do
  ActiveStorage::Attached::One.prepend RailsCom::AttachedOne
end
