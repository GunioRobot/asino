# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def get_saldo_class(amount)
    return (amount > 0 ? ' positive' : ' negative')
  end
end
