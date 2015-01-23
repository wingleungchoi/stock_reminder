class DailyPrice < ActiveRecord::Base
  belongs_to :stock, :class_name => "Stock", :foreign_key => "stock_number",  primary_key: "stock_number"
end