module Com
  module Ext::Geo
    extend ActiveSupport::Concern

    included do
      attribute :geo, :st_point, srid: 4326, geographic: true
    end

    class_methods do

      def near(lnt, lng, column: :geo)
        pt = RGeo::Geos.factory(srid: 4326).point(lnt, lng)
        select(Arel.star, arel_table[column].st_distance(Arel.spatial(pt)).as('distance')).order(distance: :asc)
      end

    end

  end
end
