# frozen_string_literal: true

module RailsCom::ActionView
  module PartialRenderer

    # 支持在views/:controller 目录下，用 _:action 开头的子目录进一步分组
    def find_template(path, locals)
      if path.include?('/') && !path.start_with?('_')
        prefixes = []
      else
        prefixes = @lookup_context.prefixes
      end

      @lookup_context.find_template(path, prefixes, true, locals, @details)
    end

    def cache_collection_render(instrumentation_payload, view, template, collection, layout)
      return yield(collection) unless will_cache?(@options, view)

      collection_iterator = collection
      keyed_collection, ordered_keys = collection_by_cache_keys(view, template, collection, layout)

      cached_partials = collection_cache.read_multi(*keyed_collection.keys)
      instrumentation_payload[:cache_hits] = cached_partials.size

      collection = keyed_collection.reject { |key, _| cached_partials.key?(key) }.values
      rendered_partials = collection.empty? ? [] : yield(collection_iterator.from_collection(collection))

      index = 0
      keyed_partials = fetch_or_cache_partial(cached_partials, template, order_by: keyed_collection.each_key) do
        rendered_partials[index].tap { index += 1 }
      end

      ordered_keys.map do |key|
        keyed_partials[key]
      end
    end

    def collection_by_cache_keys(view, template, collection, layout)
      seed = callable_cache_key? ? @options[:cached] : ->(i) { i }

      template_digest_path = view.digest_path_from_template(template)
      layout_digest_path = view.digest_path_from_template(layout)
      digest_path = "#{template_digest_path}:#{layout_digest_path}"

      collection.preload! if callable_cache_key?

      collection.each_with_object([{}, []]) do |item, (hash, ordered_keys)|
        key = expanded_cache_key(seed.call(item), view, template, digest_path)
        ordered_keys << key
        hash[key] = item
      end
    end

  end
end

ActiveSupport.on_load :action_view do
  ActionView::PartialRenderer.prepend RailsCom::ActionView::PartialRenderer
end
