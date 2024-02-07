class Broker < ApplicationRecord
	has_many :broker_contacts
	has_many :broker_project_statuses

	def self.broker_list
		brokers = []
		Broker.all.each do |broker|
			brokers += [[broker.name, broker.id]]
		end
		brokers += [["Others", -1]]
		brokers = brokers.sort
		return brokers
	end
end
