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

end
