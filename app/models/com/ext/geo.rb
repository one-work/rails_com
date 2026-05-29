module Com
  module Ext::Geo
    extend ActiveSupport::Concern

    included do
      attribute :geo, :st_point, srid: 4326, geographic: true

      before_save :get_location!, if: -> { defined?(:address) && geo_changed? }
    end

    def set_geo!(lng, lat)
      update geo: RGeo::Geos.factory(srid: 4326).point(lng, lat)
    end

    def distance
      if attributes.key? 'distance'
        attributes['distance'].to_f.to_distance(precision: 3)
      end
    end

    def geo_hash
      {
        lat: geo&.lat,
        lng: geo&.lon
      }.compact
    end

    def get_location!
      r = QqMapHelper.geocoder(lat: geo.lat, lng: geo.lon)
    rescue
    ensure
      self.address = r['address'] if r
    end

    def set_geo_by_ip!(ip)
      r = QqMapHelper.ip ip
      location = r.fetch('location', {})
      if location.present?
        self.update geo: RGeo::Geos.factory(srid: 4326).point(location['lng'], location['lat'])
      end
    end

    class_methods do

      def near(lnt, lng, column: :geo)
        pt = RGeo::Geos.factory(srid: 4326).point(lnt.to_f, lng.to_f)
        select(Arel.star, arel_table[column].st_distance(Arel.spatial(pt)).as('distance')).order(distance: :asc)
      end

    end

  end
end
