class Transaction < ApplicationRecord
	#
	# associations
	#

	belongs_to :user


	#
	# callbacks
	#

	after_create :set_user_total_points

	private

	def set_user_total_points
		# check total points in current year and add it to users
	end
end
