require 'spec_helper'

describe Hubspot::SubscriptionType do
  before do
    Hubspot.configure(hapikey: "demo")
  end

  describe ".all" do
    let(:types) do
      VCR.use_cassette("subscription_types_example") do
        Hubspot::SubscriptionType.all
      end
    end

    let(:single_type) do
      types.first
    end

    it "is array of subscription types" do
      expect(types).to be_a(Array)
      expect(single_type).to be_a(Hubspot::SubscriptionType)
    end

    it "populates item properties" do
      expect(single_type.id).to eq(354586)
      expect(single_type.portal_id).to eq(62515)
      expect(single_type.description).to eq("abandoned cart")
      expect(single_type.name).to eq("Abandoned Cart")
      expect(single_type.active).to be_truthy
    end
  end
end
