module Com
  module Ext::Geo
    extend ActiveSupport::Concern

    included do
      attr_reader :distance
      attribute :geo, :st_point, srid: 4326, geographic: true
    end

    def set_geo!(lng, lat)
      update geo: RGeo::Geos.factory(srid: 4326).point(lng, lat)
    end

    class_methods do

      def near(lnt, lng, column: :geo)
        pt = RGeo::Geos.factory(srid: 4326).point(lnt.to_f, lng.to_f)
        select(Arel.star, arel_table[column].st_distance(Arel.spatial(pt)).as('distance')).order(distance: :asc)
      end

    end

  end
end
