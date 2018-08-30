class Staff
  include Mongoid::Document
  include Mongoid::CategorizedCounterCache

  field :gender    # male, female

  belongs_to :company, counter_cache: true
  categorized_counter_cache :company do |staff|
    staff.gender.to_s
  end

end
