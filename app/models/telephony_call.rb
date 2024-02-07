class TelephonyCall < ApplicationRecord
	belongs_to :lead
	belongs_to :followup
end
