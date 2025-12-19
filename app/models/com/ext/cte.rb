module Com
  module Ext::Cte
    extend ActiveSupport::Concern

    class_methods do

      def cte_multi(conditions, column)
        ctes = {}

        conditions.each_with_index do |condition, index|
          ctes.merge! "cte_#{index}" => select(column).where(condition)
        end

        joins_sql = ctes.each_with_object([]) do |(cte_name, _), h|
          h << "JOIN #{cte_name} ON #{cte_name}.#{column} = #{table_name}.#{column}"
        end

        with(ctes).joins(*joins_sql)
      end

      def cte_intersect(conditions, column)
        query = self

        conditions.map do |condition|
          query = query.select(column).where(condition)
        end

        #intersect_sql = ctes.each_with_object([]) do |(cte_name, _), h|
        #  h << "SELECT #{column} FROM #{cte_name}"
        #end.join(' INTERSECT ')

        #with(ctes)
      end

    end

  end
end
