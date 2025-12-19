module Debug::Model
  module Many
    extend ActiveSupport::Concern

    included do
      attribute :name, :string

      belongs_to :one, optional: true
      has_many :throughs
      has_many :muches, through: :throughs

      before_validation do
        #one.name = one.name.to_s + '1'
      end
      after_validation do
        #one.name = one.name.to_s + '1'
      end
    end

    def test
      2.times do |i|
        muches.build(
          name: "test_#{i}",
          throughs_attributes: [{ many: self, name: "through_#{i}" }]
        )
      end
    end

    def test!
      test
      save
    end

  end
end
