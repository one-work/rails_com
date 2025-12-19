module RailsCom::ActionView
  module CollectionRenderer

    def render_collection(collection, view, path, template, layout, block)
      identifier = template&.identifier || path
      ActiveSupport::Notifications.instrument(
        'render_collection.action_view',
        identifier: identifier,
        layout: layout&.virtual_path,
        count: collection.length
      ) do |payload|
        spacer =
          if @options.key?(:spacer_template)
            spacer_template = find_template(@options[:spacer_template], @locals.keys)
            build_rendered_template(spacer_template.render(view, @locals), spacer_template)
          else
            ActionView::AbstractRenderer::RenderedTemplate::EMPTY_SPACER
          end

        collection_body =
          if template
            cache_collection_render(payload, view, template, collection, layout) do |filtered_collection|
              collection_with_template(view, template, layout, filtered_collection)
            end
          else
            collection_with_template(view, nil, layout, collection)
          end

        return ActionView::AbstractRenderer::RenderedCollection.empty(@lookup_context.formats.first) if collection_body.empty?

        build_rendered_collection(collection_body, spacer)
      end
    end

  end
end
ActiveSupport.on_load :action_view do
  ActionView::CollectionRenderer.prepend RailsCom::ActionView::CollectionRenderer
end