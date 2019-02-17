class WebfaceFormComponent

  OPTION_ATTRS = [:tabindex, :label, :suffix, :selected, :hint, :collection, :allow_custom_value, :fetch_url, :query_param_name, :disabled, :nested_field, :serialized_hash, :model_field_name, :model_name, :radio_options_id, :popup_hint, :has_blank]

  class NoSuchFormFieldType < Exception;end

  def initialize(model, view_context)
    @model         = model
    @view_context  = view_context
    @field_counter = {}
  end

  def method_missing(m, *args)

    attrs   = {}
    options = {}
    if args.last.kind_of?(Hash)
      attrs   = args.last
      options = separate_option_attrs(attrs)
    end
    field_type = m

    unless self.class.private_method_defined?("_#{field_type}")
      raise NoSuchFormFieldType, "Field type `#{field_type}` not supported"
    end

    field_name = if args.first.blank? || args.first.to_s =~ /!\Z/
      args.first.to_s.sub("!", "")
    else
      "#{@model.class.to_s.underscore}[#{args.first}]"
    end

    if options[:nested_field]
      field_name = modify_name_for_nested_field(field_name, options[:nested_field])
    elsif args.first && args.first.to_s.include?("[") && options[:nested_field].nil?
      field_name = modify_name_for_serialized_field(field_name)
    end

    if @field_counter[field_name]
      @field_counter[field_name] += 1
    else
      @field_counter[field_name] = 0
    end
    options[:field_counter] = @field_counter[field_name]

    options[:radio_options_id] = options[:name] if options[:name]

    options.merge!({ name: field_name, attr_name: args.first, model: @model, model_name: self.model_name})
    attrs.delete_if { |k,v| OPTION_ATTRS.include?(k) }
    attrs.merge!({ options: options })

    if attrs[:options][:label].nil?
      attrs[:options][:label] = I18n.t("models.#{field_name_for_i18n(field_name)}")
    end

    self.send("_#{field_type}", attrs)
  end

  def model_name
    if @model
      @model.class.to_s.underscore
    else
      options[:name].split("[").first
    end
  end

  private

    def _text(attrs)
      @view_context.component :text_form_field, attrs
    end

    def _password(attrs)
      @view_context.component :password_form_field, attrs
    end

    def _hidden(attrs)
      @view_context.component :hidden_form_field, attrs
    end

    def _numeric(attrs)
      @view_context.component :numeric_form_field, attrs
    end

    def _textarea(attrs)
      @view_context.component :textarea_form_field, attrs
    end

    def _checkbox(attrs)
      @view_context.component :checkbox, attrs
    end

    def _select(attrs)
      @view_context.component :select, attrs
    end

    def _editable_select(attrs)
      @view_context.component :editable_select, attrs
    end

    def _radio(attrs)
      @view_context.component :radio, attrs
    end

    def _submit(attrs)
      @view_context.component :button, attrs
    end

    def separate_option_attrs(attrs)
      option_attrs = {}
      if attrs.kind_of?(Hash)
        OPTION_ATTRS.each do |o|
          option_attrs[o] = attrs[o] if !attrs[o].nil?
        end
      end
      option_attrs
    end

    def modify_name_for_nested_field(name, association_name)
      if association_name.kind_of?(Array)
        association_name.each do |a|
          name = send("modify_name_for_nested_#{a[1]}", name, a[0])
        end
        return name
      else
        modify_name_for_nested_has_many(name, association_name)
      end
    end

    def modify_name_for_serialized_field(field_name)
      model,remainder = field_name.split("[",2)
      remainder.chomp!("]")
      field_name,remainder = remainder.split("[",2)
      "#{model}[#{field_name}][#{remainder}"
    end

    def modify_name_for_nested_has_one(name, nested_has_one_name)
      # name   == model[attribute]
      # result == model[association][attribute]
      model_name        = name.scan(/\A.*?\[/)[0].sub("[", "")
      field_names       = name.scan(/\[.*?\]/)
      actual_field_name = field_names.pop
      "#{model_name}#{field_names.join("")}[#{nested_has_one_name}_attributes]#{actual_field_name}"
    end

    def modify_name_for_nested_has_many(name, nested_has_many_name)
      # name   == model[attribute]
      # result == model[association][][attribute]
      model_name        = name.scan(/\A.*?\[/)[0].sub("[", "")
      field_names       = name.scan(/\[.*?\]/)
      actual_field_name = field_names.pop
      "#{model_name}#{field_names.join("")}[#{nested_has_many_name}_attributes][]#{actual_field_name}"
    end

    def field_name_for_i18n(fn)
      fn = fn.split("[").map { |n| n.sub("]", "") }.join(".")
    end

end
