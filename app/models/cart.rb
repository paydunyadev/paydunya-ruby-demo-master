class Cart < ActiveRecord::Base
  def total_price
  	quantity*price
  end
end
