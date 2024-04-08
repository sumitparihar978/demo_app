class Transaction < ApplicationRecord
	#
	# associations
	#

	belongs_to :user


	#
	# callbacks
	#

	before_create :set_default_country
	after_create :set_user_total_points

	private

	def set_user_total_points
		user.calculate_total_points
	end

	def set_default_country
		self.country_name = self.user.country_name if self.country_name.nil?
	end
end
