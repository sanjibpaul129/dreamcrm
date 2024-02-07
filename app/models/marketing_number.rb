class MarketingNumber < ApplicationRecord
has_many :calls
belongs_to :business_unit
end
