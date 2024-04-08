class User < ApplicationRecord
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

	private

	def get_standard_plan
		plan = Plan.get_standard_plan
		up = self.build_user_plan(plan: plan)
	end
end
