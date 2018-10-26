module CategoryAsPrefix

  class Company
    include Mongoid::Document

    field :users_count, type: Integer, default: 0
    field :active_users_count, type: Integer, default: 0
    field :inactive_users_count, type: Integer, default: 0

    embeds_many :users
  end

  class User
    include Mongoid::Document
    include Mongoid::CategorizedCounterCache

    field :status    # active, inactive

    belongs_to :company, counter_cache: true
    categorized_counter_cache :company, by: :status, prefix: true
  end

end
