require 'ostruct'
class RailsCom::Setting < OpenStruct

  def initialize(hash = {})
    @table = {}
    @hash_table = {}

    hash.each do |k, v|
      if v.is_a?(Hash)
        @table[k.to_sym] = self.class.new(v)
      elsif v.is_a?(Array)
        @table[k.to_sym] = v.map { |h| h.is_a?(Hash) ? self.class.new(h) : h }
      else
        @table[k.to_sym] = v
      end
      @hash_table[k.to_sym] = v
      new_ostruct_member!(k)
    end
  end

  def to_hash
    @hash_table.with_indifferent_access
  end

end

class RailsCom::Settings < Array

  def initialize(data = [])
    data.map do |h|
      self << RailsCom::Setting.new(h)
    end
  end

end
