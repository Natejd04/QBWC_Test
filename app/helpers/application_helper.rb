module ApplicationHelper

	# This will be the method for adding line items to orders.
    def link_to_add_fields(name, f, association)
        new_object = f.object.class.reflect_on_association(association).klass.new
        fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
          render("upp_lineitem", :f => builder)
        end
        link_to(name, "#", "data-association" => "#{association}" , "data-content" => "#{fields}", :class => "link_to_add_fields" )
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

  def comment
    # nothing between this chunk will render
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, request.query_parameters.merge({:sort => column, :direction => direction}), {:class => css_class}
  end

  def remove_class(title)
    removed = title == classed_remove ? "Wholesale Direct" : nil
    link_to c_class, request.query_parameters.merge({:remove => removed})
  end

end
