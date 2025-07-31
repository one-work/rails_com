desc '生成需要的图标'
task icons: :environment do
  icon_hash = Rails::Engine.subclasses.each_with_object({}) do |engine, h|
    icon_path = engine.root.join('config/icons.yml')
    if icon_path.exist?
      YAML.safe_load_file(icon_path).each do |k, v|
        h[k] ||= []
        h[k].concat v
      end
    end
  end

  
end