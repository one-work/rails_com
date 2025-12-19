module RailsCom::Parameters

  def require(key)
    begin
      super
    rescue ArgumentError => e
      Rails.logger.debug e.backtrace
      self[key]
    ensure
      @required_params ||= []
      @required_params << key
    end
  end

  def to_meta
    except(:business, :namespace).permit!.transform_keys!(&->(i){ ['controller', 'action'].include?(i) ? "meta_#{i}" : i }).to_h
  end

end

ActiveSupport.on_load :action_controller_base do
  ActionController::Parameters.prepend RailsCom::Parameters
end
