module Debug

  def self.use_relative_model_naming?
    true
  end

  def self.table_name_prefix
    'debug_'
  end

  def self.clear!
    Many.delete_all
    Much.delete_all
    One.delete_all
    Through.delete_all
  end

end
