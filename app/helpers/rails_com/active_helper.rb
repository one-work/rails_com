# frozen_string_literal: true
module RailsCom::ActiveHelper

  # return value by each keys which is true
  #   active_asserts(active: true, item: false)
  #   #=> 'active'
  def active_asserts(join = true, **options)
    keys = options.select { |_, v| v }.keys

    if join
      keys.join(' ')
    else
      keys.last.to_s
    end
  end

  # See examples bellow:
  # paths:
  #   active_helper paths: '/work/employees' or active_helper paths: ['/work/employees']
  # controllers:
  #   active_helper controllers: 'xxx'  or active_helper controllers: ['xxx1', 'admin/xxx2']
  # modules:
  #   active_helper modules: 'admin/oa'
  # action:
  #   active_helper 'work/employee': ['index', 'show']
  # params:
  #   active_helper controller: 'users', action: 'show', id: 371
  def active_helper_bool(paths: [], controllers: [], modules: [], check_parameters: true, check_sessions: true, **options)
    if paths.present?
      Array(paths).each do |path|
        return true if current_page?(path, check_parameters: check_parameters)
      end
      return false
    end

    if controllers.present?
      if (Array(controllers) & [controller_name, controller_path]).size > 0
        return true
      else
        return false
      end
    end

    if modules.present?
      this_modules = controller_path.split('/')
      this_modules.pop
      _this_modules = []
      while this_modules.size >= 1
        this_modules.each.with_index do |_, index|
          _this_modules << this_modules[0, index + 1].join('/')
        end
        this_modules.shift
      end
      if (Array(modules) & _this_modules).size > 0
        return true
      else
        return false
      end
    end

    present_params = request.query_parameters.merge request.path_parameters.except(:business, :namespace, :controller, :action)
    if current_page?(check_parameters: check_parameters, **present_params.merge(options))
      return true
    end

    if options.find { |key, value| [controller_name, controller_path].include?(key.to_s.delete_prefix('/')) && Array(value).include?(action_name) }
      return true
    end

    if check_sessions
      options.each do |k, v|
        return true if !present_params.key?(k) && session.key?(k) && session[k].to_s == v.to_s
      end
    end

    false
  end

  def active_helper(paths: [], controllers: [], modules: [], active: nil, item: nil, check_parameters: true, check_sessions: true, **options)
    if active_helper_bool(paths: paths, controllers: controllers, modules: modules, check_parameters: check_parameters, check_sessions: check_sessions, **options)
      active
    else
      item
    end
  end

  def filter_params(options = {})
    only = Array(options.delete(:only)).map(&:to_s)
    except = Array(options.delete(:except)).map(&:to_s)
    query = request.GET.dup
    options.stringify_keys!
    query.merge! options
    query.reject! { |key, _| request.GET[key] == options[key].to_s }  # 如果当前值相等，则可反查

    if only.present?
      query = query.extract!(*only)
    else
      excepts = except + ['commit', 'utf8', 'page']
      query.except!(*excepts)
    end

    if query.length > 1
      query.reject! { |_, value| value.blank? }
    else
      query.reject! { |_, value| value.nil? }
    end
    query
  end

end
