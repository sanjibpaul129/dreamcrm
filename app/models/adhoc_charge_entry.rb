class AdhocChargeEntry < ApplicationRecord
	belongs_to :booking
	belongs_to :adhoc_charge
end
