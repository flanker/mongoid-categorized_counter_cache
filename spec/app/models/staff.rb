class Staff
  include Mongoid::Document
  include Mongoid::CategorizedCounterCache

  field :name
  field :gender    # male, female

  belongs_to :company, counter_cache: true
  categorized_counter_cache :company, by: :gender

end
