class Company
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :staffs_male_count, type: Integer, default: 0
  field :staffs_female_count, type: Integer, default: 0

  embeds_many :staffs
end
