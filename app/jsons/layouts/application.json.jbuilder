if ['index'].include? params[:action]
  json.results JSON.parse(yield)
  json.partial! 'pagination', items: instance_variable_get("@#{controller_name.pluralize}") if defined? instance_variable_get("@#{controller_name.pluralize}")
else
  json.merge! JSON.parse(yield)
end
