require 'spec_helper'

# Dummy class
class Offer;end

RSpec.describe WebfaceRails::FormComponentHelper do

  before(:each) do
    @component_form = WebfaceRails::FormComponentHelper.new(Offer.new, nil)
  end

  it "modifies field name for nested has_one association" do
    field_name = "offer[payment_method_type]"
    assoc_name = :payment_method
    expect(@component_form.send(:modify_name_for_nested_has_one, field_name, assoc_name)).to eq(
      "offer[payment_method_attributes][payment_method_type]"
    )
    field_name = "offer[payment_method_instructions_attributes][][name]"
    expect(@component_form.send(:modify_name_for_nested_has_one, field_name, assoc_name)).to eq(
      "offer[payment_method_instructions_attributes][][payment_method_attributes][name]"
    )
  end

  it "modifies field name for nested has_many association" do
    field_name = "offer[instructions]"
    assoc_name = :payment_method_instructions
    expect(@component_form.send(:modify_name_for_nested_has_many, field_name, assoc_name)).to eq(
      "offer[payment_method_instructions_attributes][][instructions]"
    )
  end

  it "modifies field name for multiple levels of associations" do
    field_name = "offer[name]"
    assoc_name = [[:payment_method_instructions, :has_many], [:payment_method, :has_one]]
    expect(@component_form.send(:modify_name_for_nested_field, field_name, assoc_name)).to eq(
      "offer[payment_method_instructions_attributes][][payment_method_attributes][name]"
    )
  end

  it "modifies field name for serialized field hash" do
    expect(@component_form.send(:modify_name_for_serialized_field, "offer[serialized_field[hello][]]")).to eq(
      "offer[serialized_field][hello][]"
    )

    expect(@component_form.send(:modify_name_for_serialized_field, "offer[serialized_field[hello]]")).to eq(
      "offer[serialized_field][hello]"
    )

    expect(@component_form.send(:modify_name_for_serialized_field, "offer[serialized_field[hello][hi]]")).to eq(
      "offer[serialized_field][hello][hi]"
    )

    expect(@component_form.send(:modify_name_for_serialized_field, "quiz_question[question[ru]]")).to eq(
      "quiz_question[question][ru]"
    )
  end

end
