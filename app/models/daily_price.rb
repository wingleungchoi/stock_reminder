class DailyPrice < ActiveRecord::Base
  belongs_to :stock, foreign_key: "stock_number"
end