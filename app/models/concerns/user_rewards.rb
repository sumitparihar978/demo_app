module UserRewards
	extend ActiveSupport::Concern

	def calculate_total_points
		update_points_if_expired
		total_amount = transactions.where(country_name: self.country_name).sum(:amount)
		total_points = (total_amount / 100).to_i * 10
		# Check if there are transactions in different countries
		foreign_transactions_amount = transactions.where.not(country_name: self.country_name).sum(:amount)

		# If there are transactions in different countries, double the points
		total_foreign_points = ((foreign_transactions_amount / 100).to_i * 10) * 2
		total_points += total_foreign_points
		update(total_points: total_points)
		# check for reards
		check_for_coffee_reward
		apply_cash_rebate

		# check plans
		assign_plan

		# free movie
		apply_free_movie_rewards

		# airport lounge access
		check_lounge_access_rewards

		# quaterly bonus

		check_quarterly_spending_bonus
	end

	private

	def get_standard_plan
		plan = Plan.get_standard_plan
		up = self.build_user_plan(plan: plan)
	end

	def assign_plan
		current_points = total_points
		if current_points >= 5000
			create_or_update_user_plan('platinum')
		elsif current_points >= 1000
			create_or_update_user_plan('gold')
		end
	end

	def create_or_update_user_plan(plan_name)
		plan = Plan.find_by("lower(name) = ?", plan_name)
		if user_plan
			user_plan.update(plan: plan)
		else
			UserPlan.create(user: self, plan: plan)
		end
	end

	def update_points_if_expired
		if self.points_last_reset_at.nil?
			last_reset_date = transactions.minimum(:created_at)
		else
			last_reset_date = self.points_last_reset_at
		end
		if last_transaction_date < 1.year.ago
			update(total_points: 0, points_last_reset_at: last_reset_date)
		end
	end

	def check_for_coffee_reward
		current_month = Date.current.month
		current_year = Date.current.year

		current_month_points = transactions.where('extract(month from created_at) = ? AND extract(year from created_at) = ?', current_month, current_year).sum(:points)
		if current_month_points >= 100
			# Give coffee reward
			reward = rewards.new(special_reward: "Free Coffee")
			if birth_month == current_month
				reward.rewarded = true
			end

			reward.save
		end
	end

	def birth_month
		birth_date&.month
	end

	def apply_cash_rebate
		qualifying_transactions_count = transactions.where('amount > ?', 100).count
		if qualifying_transactions_count >= 10
			# Apply 5% cash rebate
			rebate_amount = transactions.where('amount > ?', 100).sum(:amount) * 0.05

			reward = rewards.new(special_reward: "5% Cash rebate")
			reward.rewarded = true
			reward.save

			# add this to user wallets
			wallet = self.wallet.present? ? self.wallet : self.build_wallet
			wallet.amount += rebate_amount
			wallet.save
		end
	end

	def apply_free_movie_rewards
		if new_user? && within_60_days? && spending_over_1000?
			# Give free movie ticket
			reward = rewards.new(special_reward: "free movie ticket")
			reward.rewarded = true
			reward.save
		end
	end
  
	def new_user?
		transactions.empty?
	end

	def first_transaction_date
		transactions.minimum(:created_at)
	end

	def within_60_days?
		first_transaction_date.present? && first_transaction_date >= 60.days.ago
	end

	def spending_over_1000?
		transactions.sum(:amount) > 1000
	end

	def check_lounge_access_rewards
		if gold_tier?
			give_lounge_access_rewards
		end
	end
  
	def gold_tier?
		user_plan&.plan&.name == 'gold'
	end

	def give_lounge_access_rewards
		reward = rewards.new(special_reward: "Airport lounge access rewards")
		reward.rewarded = true
		reward.save
	end

	def check_quarterly_spending_bonus
		if quarterly_spending_over_2000?
			give_quarterly_points
		end
	end

	def quarterly_spending_over_2000?
		current_quarter_spending > 2000
	end

	def current_quarter_spending
		quarter_start = Date.today.beginning_of_quarter
		quarter_end = Date.today.end_of_quarter
		transactions.where(created_at: quarter_start..quarter_end).sum(:amount)
	end

	def give_quarterly_points
		# Give 100 points
		message =  "100 points given to user #{name} for spending over $2000 in the current quarter."
		transactions.update(points: 100, note: message)
	end
end