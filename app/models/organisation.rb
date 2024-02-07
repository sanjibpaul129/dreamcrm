class Organisation < ApplicationRecord
validates_uniqueness_of :email
validates_uniqueness_of :name
has_many :personnels
has_many :companies
has_many :business_units	
has_many :emails
end
