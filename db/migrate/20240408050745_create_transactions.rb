class CreateTransactions < ActiveRecord::Migration[6.0]
	def change
		create_table :transactions, id: :uuid do |t|
			t.float :amount, default: 0.0
			t.references :user, foreign_key: true, type: :uuid, index: true
			t.integer :points, default: 0
			t.text :note

			t.timestamps
		end
	end
end
