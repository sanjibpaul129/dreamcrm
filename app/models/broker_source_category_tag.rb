class BrokerSourceCategoryTag < ApplicationRecord
	belongs_to :broker_contact
	belongs_to :source_category
end
