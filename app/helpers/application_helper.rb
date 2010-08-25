# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def get_saldo_class(amount)
    return (amount > 0 ? ' positive' : ' negative')
  end
  
  def note(title = 'Notiz', text = 'Bitte Text angeben')
    "
    <div class=\"note\">
      <a href=\"#\">  
        <h2>#{title}</h2>  
        <p>#{text}</p>  
      </a>
    </div>
    "
  end
end
