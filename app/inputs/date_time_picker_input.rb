## app/inputs/date_time_picker_input.rb
class DateTimePickerInput < SimpleForm::Inputs::Base
  def input
    template.content_tag(:input, class: 'input-group date form_datetime') do
      template.concat @builder.text_field(attribute_name, input_html_options)
    #   template.concat span_remove
    #   template.concat span_table
end
  
    # @builder.text_field(attribute_name, input_html_options) + \
    # @builder.hidden_field(attribute_name, { :class => attribute_name.to_s + "-alt"})
  
  end

  def input_html_options
    super.merge({class: 'form-control', readonly: true})
  end

  def span_remove
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_remove
    end
  end

  def span_table
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_table
    end
  end

  def icon_remove
    "<i class='glyphicon glyphicon-remove'></i>".html_safe
  end

  def icon_table
    "<i class='glyphicon glyphicon-th'></i>".html_safe
  end

end