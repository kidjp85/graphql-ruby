module GraphQL
  module Relay
    class ConnectionResolve
      def initialize(field, underlying_resolve, max_page_size: nil)
        @field = field
        @underlying_resolve = underlying_resolve
        @max_page_size = max_page_size
      end

      def call(obj, args, ctx)
        nodes = @underlying_resolve.call(obj, args, ctx)
        lazy_method = ctx.query.lazy_method(nodes)
        if lazy_method
          @field.prepare_lazy(nodes, args, ctx).then { |resolved_nodes|
            build_connection(resolved_nodes, args, obj)
          }
        else
          build_connection(nodes, args, obj)
        end
      end

      private

      def build_connection(nodes, args, parent)
        connection_class = GraphQL::Relay::BaseConnection.connection_for_nodes(nodes)
        connection_class.new(nodes, args, field: @field, max_page_size: @max_page_size, parent: parent)
      end
    end
  end
end
