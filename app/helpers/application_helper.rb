# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def get_saldo_class(amount)
    return (amount > 0 ? ' positive' : ' negative')
  end
  
  def note(title = 'Notiz', text = 'Bitte Text angeben')
    "
    <div id=\"note\" class=\"note\">
      <a href=\"#\">  
        <h2>#{title}</h2>  
        <p>#{text}</p>  
      </a>
    </div>
    "
  end
  
  def trend_img(number)
     return image_tag 'icons/green_arrow_up.png' if number > 0
     return image_tag 'icons/red_arrow_down.png' if number < 0
     return image_tag 'icons/arrow_null.png' # must be 0
  end
end
