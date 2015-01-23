class Stock < ActiveRecord::Base
  has_many :daily_prices, :class_name => "DailyPrice", :foreign_key => "stock_number",  primary_key: "stock_number"
end