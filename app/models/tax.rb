class Tax < ApplicationRecord
	belongs_to :business_unit

def self.from_to_hash(business_unit_id)
	from_to_hash={}
	taxes=where(business_unit_id: business_unit_id)
	sorted_taxes=taxes.sort_by{|x| x.applicable_from}
	sorted_taxes.each_with_index do |tax,number|
		if sorted_taxes[number+1]==nil
		from_to_hash[tax.id]=[tax.applicable_from.to_datetime,(Time.now+30.days).beginning_of_day.to_datetime]
		else
		from_to_hash[tax.id]=[tax.applicable_from.to_datetime,sorted_taxes[number+1].applicable_from.to_datetime]
		end
	end
	return from_to_hash
end

end
