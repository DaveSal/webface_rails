require 'spec_helper'
require 'active_support/all'

# Dummy class
class Offer;end

RSpec.describe WebfaceComponentHelper do

  before(:each) do
    @model                 = double("model")
    @model_with_collection = double("model with collection")
    @target_model          = double("target_model")
    @dummy                 = double("dummy")
    allow(@dummy).to        receive(:id).and_return(nil)
    allow(@target_model).to receive(:id).and_return(5)
    @options = { name: "model[association1][association2][][field_name]", field_counter: 5, model_name: "model", nested_field: [[:association1, :has_one], [:association2, :has_many]], attr_name: "field_name", model: @model }
  end

  include WebfaceComponentHelper

  # This is a dummy method so we don't need to import I18n from rails
  def t(key)
    key.include?("no_value") ? "[no value]" : key
  end

  it "breaks down associations chain used in field name into an array" do
    field_1 = { model: Offer.new, nested_field: [[:association1, :has_one], [:association2, :has_many, 1]] }
    field_2 = { model: Offer.new, nested_field: [[:association1, :has_many, 1], [:association2, :has_many, 2]] }
    field_3 = { model: Offer.new, nested_field: [[:association1, :has_many], [:association2, :has_many]] }
    field_4 = { model: Offer.new, nested_field: [[:association1, :has_many], [:association2, :has_one]] }
    expect(get_field_names_chain_from_nested_field_param_and_model(field_1)).to eq(
      ["offer", :association1, [:association2, 1]]
    )
    expect(get_field_names_chain_from_nested_field_param_and_model(field_2)).to eq(
      ["offer", [:association1,1], [:association2, 2]]
    )
    expect(get_field_names_chain_from_nested_field_param_and_model(field_3)).to eq(
      ["offer", [:association1,nil], [:association2, nil]]
    )
    expect(get_field_names_chain_from_nested_field_param_and_model(field_4)).to eq(
      ["offer", [:association1,nil], :association2]
    )
  end

  describe "getting value from a model" do

    it "gets value for the field from the model when model is not saved" do
      allow(@target_model).to receive(:id).and_return(nil)
      expect(@target_model).to receive(:field_name).and_return("value")
      expect(@model_with_collection).to receive(:association2).and_return([@dummy,@dummy,@dummy,@dummy,@dummy,@target_model])
      expect(@model).to receive(:association1).and_return(@model_with_collection)
      expect(get_value_for_field_name(@options)).to eq("value")
    end

    it "uses a different field_name for the model if specified" do
      allow(@target_model).to receive(:id).and_return(nil)
      expect(@target_model).to receive(:attr_name).and_return("value")
      expect(@model_with_collection).to receive(:association2).and_return([@dummy,@dummy,@dummy,@dummy,@dummy,@target_model])
      expect(@model).to receive(:association1).and_return(@model_with_collection)
      expect(get_value_for_field_name(@options.merge(model_field_name: "attr_name"))).to eq("value")
    end

    it "gets value for an existing model (with id) in a has_many association" do
      @options[:nested_field] = [[:association1, :has_one], [:association2, :has_many, 5]]
      allow(@target_model).to receive(:id).and_return(5)
      expect(@target_model).to receive(:attr_name).and_return("value")
      expect(@model_with_collection).to receive(:association2).and_return([@dummy,@target_model])
      expect(@model).to receive(:association1).and_return(@model_with_collection)
      expect(get_value_for_field_name(@options.merge(model_field_name: "attr_name"))).to eq("value")
    end

  end

  describe "getting value from a serialized Hash stored in a field" do
    
    it "gets value from a single level serialized hash" do
      allow(@model).to receive(:serialized_field).and_return({ hello: "world" })
      expect(get_value_for_field_name({name: "model[serialized_field][hello]", model_name: "model", attr_name: "serialized_field", model: @model })).to eq("world")
    end

    it "gets value from a multiple level serialized hash" do
      allow(@model).to receive(:serialized_field).and_return({ hello: { hi: "world" }})
      expect(get_value_for_field_name({name: "model[serialized_field][hello][hi]", model_name: "model", attr_name: "serialized_field", model: @model })).to eq("world")
    end

    it "gets value from a multiple level serialized hash with arrays" do
      allow(@model).to receive(:serialized_field).and_return({ hello: { hi: ["whole", "wide", "world"] }})
      expect(get_value_for_field_name({name: "model[serialized_field][hello][hi][2]", model_name: "model", attr_name: "serialized_field", model: @model })).to eq("world")
    end

  end

  it "gets value for the field from params" do
    @options[:model] = nil
    expect(self).to receive(:params).and_return(HashWithIndifferentAccess.new({model: { association1_attributes: { association2_attributes: [0,0,0,0,0, { "field_name" => "value"}]}}}))
    expect(get_value_for_field_name(@options)).to eq("value")
  end

  it "gets error message for the field from the model" do
    @options[:nested_field] = [[:association1, :has_one], [:association2, :has_many, 5]]
    expect(@target_model).to receive(:errors).and_return(HashWithIndifferentAccess.new({ field_name: "error message"}))
    allow(@target_model).to receive(:id).and_return(5)
    expect(@model_with_collection).to receive(:association2).and_return([@dummy,@target_model])
    expect(@model).to receive(:association1).and_return(@model_with_collection)
    expect(get_error_for_field_name(@options)).to eq("error message")
  end

  describe "SelectComponent helpers" do

    it "prepares a collection of field names & values out of Hash" do
      c = { key1: "value1", key2: "value2", key3: "value3" }
      expect(prepare_select_collection(c)).to eq([["key1", "value1"], ["key2", "value2"], ["key3", "value3"]])
    end

    it "prepares a collection of field names & values out of Array" do
      c = ["value1", "value2", "value3"]
      expect(prepare_select_collection(c)).to eq([["value1", "value1"], ["value2", "value2"], ["value3", "value3"]])
    end

    it "prepares a collection of field names and includes an blank value first" do
      c = ["value1", "value2", "value3"]
      expect(prepare_select_collection(c, selected: "value1", blank_option: true)).to eq([["null", "[no value]"], ["value1", "value1"], ["value2", "value2"], ["value3", "value3"]])
    end

    it "returns selected value for the SelectComponent field" do
      c = { key1: "value1", key2: "value2", key3: "value3" }
      options = { selected: "key1", collection: c }
      expect(select_component_get_selected_value(options, :display)).to eq("value1")
    end

  end

end
