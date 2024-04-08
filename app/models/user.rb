class User < ApplicationRecord
	include UserRewards
	#
	# associations
	#

	has_many :transactions, dependent: :destroy
	has_many :rewards, dependent: :destroy
	has_one :user_plan, dependent: :destroy
	has_one :wallet, dependent: :destroy


	#
	# callbacks
	#

	before_create :get_standard_plan

	#
	# methods
	#

end
