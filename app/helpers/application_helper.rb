module ApplicationHelper

	# This will be the method for adding line items to orders.
    def link_to_add_fields(name, f, association)
        new_object = f.object.class.reflect_on_association(association).klass.new
        fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
          render("upp_lineitem", :f => builder)
        end
        link_to(name, "#", "data-association" => "#{association}" , "data-content" => "#{fields}", :class => "link_to_add_fields" )
    end

    def flash_class(level)
	    case level
	        when :notice then "alert alert-warning"
	        when :success then "alert alert-success"
	        when :error then "alert alert-error"
	        when :alert then "alert alert-error"
	    end
	end


	def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do 
              concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
              concat message 
            end)
    end
    nil
  end

end
