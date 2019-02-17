module WebfaceComponentHelper

  def webface(tag_name, component: nil, attrs: {})

    component = "#{component.to_s.camelize}Component" unless component.nil?

    if attrs[:property_attr]
      property_attrs = attrs[:property_attr].split(/,\s*?/)
      property_attrs.map! { |a| "#{a.strip}:data-#{a.strip.gsub("_","-")}" }
      attrs[:property_attr] = property_attrs.join(", ")
    end

    # convert short data attribute names to proper longer ones
    webface_data = {}
    webface_data[:component_class]                = component
    webface_data[:component_property]             = attrs.delete(:property)
    webface_data[:component_part]                 = attrs.delete(:part)
    webface_data[:component_roles]                = attrs.delete(:roles)
    webface_data[:component_attribute_properties] = attrs.delete(:property_attr)
    webface_data[:component_display_value]        = attrs.delete(:display)

    content_tag(tag_name, { data: webface_data.merge(attrs.delete(:data) || {})}.merge(attrs)) do
      yield if block_given?
    end
  end

  def component(name, attrs={}, &block)
    render partial: "webface_components/#{name}", locals: { options: attrs.delete(:options) || {}, attrs: attrs, block: block }
  end

  def component_block(component, tag_name="div", attrs={}, &block)
    webface(tag_name, component: component, attrs: attrs, &block)
  end

  def property(property, tag_name="span", attrs={}, &block)
    webface(tag_name, attrs: attrs.merge({ property: property}), &block)
  end

  def component_part(part_name, tag_name="div", attrs={}, &block)
    webface(tag_name, attrs: attrs.merge({ part: part_name}), &block)
  end

  def button_link(caption, path, options={})
    component_block :button, "a", { class: "button", href: path, data: { prevent_native_click_event: "false" }}.merge(options) do
      caption
    end
  end

  def component_form(model, action=nil, attrs={}, &block)

    if model.new_record?
      action = send("#{model.class.to_s.underscore.pluralize}_path") unless action
      method_field = ""
    else
      action = send("#{model.class.to_s.underscore}_path", model.to_param) unless action
      method_field = content_tag(:input, "", type: "hidden", name: "_method", value: "PATCH")
    end

    auth_token_field = content_tag(:input, "", value: form_authenticity_token, type: "hidden", name: "authenticity_token")

    f = WebfaceFormComponent.new(model, self)
    content = capture(f, &block)
    content_tag(:form, { action: action, method: 'POST', "accept-charset" => "UTF-8", "enctype" => "multipart/form-data" }.merge(attrs)) do
      concat content
      concat method_field
      concat auth_token_field
    end
  end

  def post_button_link(caption, path, verb, options={})
    render partial: "webface_components/post_button_link", locals: { caption: caption, path: path, verb: verb, options: options }
  end

  # Attention! This method changes attrs passed to it,
  # as if `attrs` was passed by reference! That's why we use `eval` and
  # binding.
  def data_attrs_and_values!(attrs, bdg, names=[])
    data_hash = {}
    names.each do |n|
      data_hash[n] = eval("attrs.delete(:#{n})", bdg)
    end
    data_hash
  end

  def component_template(name, tag_name="div", attrs={}, &block)
    attrs[:data] ||= {}
    attrs[:data][:component_template] = "#{name.to_s.camelize}Component"
    component_block(nil, tag_name, attrs, &block)
  end

  def prepare_select_collection(c, selected: nil, blank_option: false)

    if c
      collection = c.dup
    else
      return []
    end

    if collection.kind_of?(Array)
      if !collection[0].kind_of?(Array)
        collection.map! { |option| [option, option] }
      end
    elsif collection.kind_of?(Hash)
      collection = collection.to_a
    end

    if blank_option
      collection.insert(0,["null", t("views.select_boxes.no_value")])
    end

    collection.map! { |option| [option[0].to_s, option[1].to_s] }
    collection

  end

  def select_component_get_selected_value(options, type=:input)

    input_value = if options[:selected]
      options[:selected]
    elsif options[:name]
      get_value_for_field_name(options)
    end

    if type == :input
      input_value
    else
      if options[:collection].blank? && !get_value_for_field_name(options)
        return get_value_for_field_name(options, from_params: true)
      end
      prepare_select_collection(options[:collection]).to_h[input_value]
    end

  end

  def get_value_for_field_name(options, from_params: false)

    @model_array_fields_counter ||= {}

    if options[:name] && options[:name].include?("[")
      names       = get_field_names_chain_from_nested_field_param_and_model(options)
      model_name  = names.shift

      if options[:model] && !from_params
        field_name = options[:model_field_name] || options[:attr_name]
        if field_name.blank?
          return nil
        else
          if options[:nested_field]
            model = get_target_model(names, options)
            model.send(field_name) if model
          else
            field = options[:model].send(names.shift)
            names.each do |n|
              return nil if n.nil? || field.nil?
              # This deals with fields that are arrays, for example quiz_question[answers][en][]
              # In case field name ends with [] (empty string in `n`), we start counting how many fields
              # with such a name exist and pull values from the model's array stored in that field.
              if n.to_s == ""
                @model_array_fields_counter[options[:name]] ||= 0
                field = field[@model_array_fields_counter[options[:name]]]
                @model_array_fields_counter[options[:name]] = @model_array_fields_counter[options[:name]] + 1
              else
                field = field[n]
              end
            end
            return field
          end
        end
      else
        field_name = options[:attr_name]
        value = params[options[:model_name]]
        names.each do |fn|
          value = if fn.kind_of?(Array) && value
            m = value["#{fn[0]}_attributes"]
            m[options[:field_counter]] if m
          else
            value["#{fn}_attributes"] if value
          end
        end
        return value[field_name] if value
      end
    else
      params[options[:name]]
    end
  end

  def get_error_for_field_name(options)
    names      = get_field_names_chain_from_nested_field_param_and_model(options)
    model_name = names.shift
    field_name = options[:attr_name]
    return unless field_name

    if !options[:model].blank? && model = get_target_model(names, options)
      model.errors[field_name]
    end
  end

  def get_field_names_chain_from_nested_field_param_and_model(options)
    result = [options[:model].class.to_s.underscore]

    # associated model
    if assoc = options[:nested_field]
      assoc.each do |a|
        if a[1] == :has_one
          result << a[0]
        else
          result << [a[0], a[2]]
        end
      end

    # serialized hash
    elsif options[:name]
      result = []
      options[:name].split("[").map { |n| n.chomp("]") }.each do |n|
        n = if n =~ /\A\d+\Z/
          n.to_i
        else
          n.to_sym
        end
        result << n
      end
    end
    result
  end

  def get_target_model(names, options)
    model = options[:model]
    return model unless options[:nested_field]

    names.each_with_index do |fn,i|
      return nil if model.nil?
      model = if fn.kind_of?(Array)
        collection = model.send(fn[0])
        if fn[1]
          collection.select { |m| fn[1] == m.id }.first
        else
          collection[options[:field_counter]]
        end
      else
        model.send(fn)
      end
    end
    model
  end

end
