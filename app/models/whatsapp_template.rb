class WhatsappTemplate < ApplicationRecord
	belongs_to :business_unit
	has_many :whatsapp_images

	def lead_type
		lead_type = nil
		if self.live == true
			lead_type = "live"
		elsif self.lost == true
			lead_type = "lost"
		elsif self.ad_hoc == true
			lead_type = "adhoc"
		elsif self.fresh == true
			lead_type = "fresh"
		elsif self.site_visited == true
			lead_type = "site visited"
		elsif self.Booked == true
			lead_type = "booked"
		elsif self.qualified == true
			lead_type = "qualified"
		elsif self.visit_organised == true
			lead_type = "OV"
		else
			lead_type = ""
		end
		return lead_type
	end
end
