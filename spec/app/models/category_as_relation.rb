module CategoryAsRelation

  class Company
    include Mongoid::Document

    field :users_count, type: Integer, default: 0
    field :users_west_count, type: Integer, default: 0
    field :users_east_count, type: Integer, default: 0

    has_many :users
  end

  class City
    include Mongoid::Document

    field :name
    field :region    # west, east

  end

  class User
    include Mongoid::Document
    include Mongoid::CategorizedCounterCache

    field :status    # active, inactive

    belongs_to :city

    belongs_to :company, counter_cache: true
    categorized_counter_cache :company, by: 'city.region'
  end

end
