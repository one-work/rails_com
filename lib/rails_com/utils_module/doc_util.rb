module DocUtil
  extend self

  def docs_hash
    if Rails.root.join('config/doc.yml').exist?
      doc_hash = YAML.load_file(Rails.root.join('config/doc.yml'))
    else
      doc_hash = {}
    end

    Rails::Engine.subclasses.each_with_object(doc_hash) do |engine, h|
      doc_path = engine.root.join('config/doc.yml')
      if doc_path.exist?
        YAML.safe_load_file(doc_path).each do |k, v|
          h[k] ||= []
          h[k].concat v
        end
      end
    end
  end

end