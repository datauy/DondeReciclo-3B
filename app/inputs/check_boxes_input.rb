class CheckBoxesInput < Formtastic::Inputs::CheckBoxesInput

  def to_html
    unless options[:nested_set]
      super
    else
      nested_wrapping(options)
    end
  end

  def nested_wrapping(options)
    choices_wrapping do
      hidden_field_for_all <<
      html_template_for_nested_set(options)
    end
  end

  def html_template_for_nested_set(options)
    options[:collection].map{|menu|
      html_for_nested(menu)
    }.join("\n").html_safe
  end

  def html_for_nested(menu, from_nested=false, select_all=true, with_parents=false )
    choice = [menu.name , menu.id]
    template.content_tag(:li, class: "choice #{from_nested ? "" : "collapsable-section"}") do
      if from_nested
        choice_html(choice)
      else
        if with_parents
          parent_label = template.content_tag(
            :label,
            custom_checkbox(choice) + choice_label(choice),
            label_html_options.merge(:for => parent_id(options[:parent]) + choice_value(choice).to_s, :class => "primary")
          )
        elsif select_all
          parent_label = template.content_tag(
            :label,
            all_checkbox(choice) + choice_label(choice),
            label_html_options.merge(:for => parent_id(options[:parent]) + choice_value(choice).to_s, :class => "select_all primary")
          )
        else
          parent_label = template.content_tag( :label, choice_label(choice), label_html_options )
        end
        template.content_tag(
          :span,
          template.content_tag(:i, "", class: "expand"),
          class: "expand-area") + parent_label  << sub_children(menu)
      end
    end
  end
  #
  def all_checkbox(choice)
    value = choice_value(choice)
    template.check_box_tag(
      parent_id(options[:parent]) + value.to_s,
      value,
      false,
      extra_html_options(choice).merge( :id => parent_id(options[:parent]) + value.to_s, :disabled => disabled?(value) )
    )
  end
  #
  def custom_checkbox(choice)
    value = choice_value(choice)
    template.check_box_tag(
      options[:parent],
      value,
      options[:parent_ids].include?(value),
      extra_html_options(choice).merge(:id => parent_id(options[:parent]) + value.to_s, :disabled => disabled?(value), :required => false)
    )
  end
  #
  def sub_children(menu)
    template.content_tag( :ul,
     menu.children.collect do |child|
       html_for_nested(child, true)
     end.join("\n").html_safe,
     {:class=>"sub_item-#{menu.id} sub-item"}
    )
  end
  def parent_id(parent)
    pp = parent.gsub("[","_")
    pp.gsub!("]","")
    return pp
  end
end
