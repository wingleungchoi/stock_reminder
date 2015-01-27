class Stock < ActiveRecord::Base
  has_many :daily_prices, :class_name => "DailyPrice", :foreign_key => "stock_number",  primary_key: "stock_number"

  def recommend # return sell or buy
    if self.daily_prices.first.moving_25 > self.daily_prices[1].moving_250
      true
    else
      false
    end
  end
end