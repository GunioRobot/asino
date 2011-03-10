module ApplicationHelper
  
  def get_saldo_class(amount)
    return (amount > 0 ? ' positive' : ' negative')
  end
  
  def li_menu(current, action = nil)
    return raw '<li class="active">' if current.include? controller.controller_name and action.nil?
    return raw '<li class="active">' if current.include? controller.controller_name and action.include? controller.action_name
    raw '<li>'
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
  
  # helper to display sortable links and their current sort state in table headers
  def sortlink(label, param)
	  if params[:order] == param
	    link_to raw("#{label} &darr;"), "#{request.path}?order=#{param} desc"
	  elsif params[:order] == "#{param} desc"
	    link_to raw("#{label} &uarr;"), "#{request.path}?order=#{param}"
	  else
      link_to label, "#{request.path}?order=#{param}"
    end
  end
  
  def currency(number)
     number_to_currency(number, :unit => "&euro;", :separator => ",", :delimiter => ".", :format => "%n %u")
   end

end