class StocksController < ApplicationController
  def front
    @stock = Stock.first
    #gon.date = ["A","B",'C','D','E','F','G']
    gon.date = @stock.daily_prices.take(70).map { |daily_price| daily_price.date }.reverse
    gon.moving_250s = @stock.daily_prices.take(70).map { |daily_price| daily_price.moving_250 }.reverse
    gon.moving_25s = @stock.daily_prices.take(70).map { |daily_price| daily_price.moving_25 }.reverse
    gon.candle_sticks = @stock.daily_prices.take(70).map{ |e| y = {x: e.date.gsub(/[-]/, ","), y: [e.open, e.high, e.low, e.close] } }.to_json
  end

  def search
    if   params[:stock_number] != "" && (1..10).include?(params[:stock_number].to_i)
      @stock = Stock.find_by(stock_number: params[:stock_number])
      gon.date = @stock.daily_prices.take(70).map { |daily_price| daily_price.date }.reverse
      gon.moving_250s = @stock.daily_prices.take(70).map { |daily_price| daily_price.moving_250 }.reverse
      gon.moving_25s = @stock.daily_prices.take(70).map { |daily_price| daily_price.moving_25 }.reverse    
      gon.candle_sticks = @stock.daily_prices.take(70).map{ |e| y = {x: e.date.gsub(/[-]/, ","), y: [e.open, e.high, e.low, e.close] } }.to_json
      render 'front'
    else
      flash[:danger] = "Sorry, we only accept enquiries about stock numbers from 0 to 10."      
      redirect_to root_path
    end
  end
end