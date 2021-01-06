require 'spec_helper'

describe Hubspot::Subscription do
  describe ".status" do
    before do
      Hubspot.configure(hapikey: "demo")
    end
    let(:subscription) do
      VCR.use_cassette("subscription_status_example") do
        Hubspot::Subscription.status(email: "john@doe.com")
      end
    end

    it "populates properties" do
      expect(subscription.subscribed).to be_truthy
      expect(subscription.marked_as_spam).to be_falsy
      expect(subscription.bounced).to be_truthy
      expect(subscription.status).to eq "subscribed"
      expect(subscription.subscription_statuses).to be_empty
    end
  end

  describe ".opt_in" do
    before do
      Hubspot.configure(hapikey: ENV["POST_HUBSPOT_HAPI_KEY"])
    end

    let!(:opt_in) do
      VCR.use_cassette("subscription_opt_in_example") do
        Hubspot::Subscription.opt_in(email: "john@doe.com", type_id: 8398069)
      end
    end

    it "succeed" do
      expect(opt_in["success"]).to be_truthy
    end

    it "opt in user" do
      subscription = VCR.use_cassette("subscription_opt_in_status_example") do
        Hubspot::Subscription.status(email: "john@doe.com")
      end

      expect(subscription.subscribed).to be_truthy
      expect(subscription.marked_as_spam).to be_falsy
      expect(subscription.bounced).to be_truthy
      expect(subscription.status).to eq "subscribed"
      expect(subscription.subscription_statuses).to include(
        {
          "id" => a_kind_of(Integer),
          "legalBasis" => "LEGITIMATE_INTEREST_CLIENT",
          "legalBasisExplanation" => "User opted in through Leanlife platform.",
          "optState" => "OPT_IN",
          "subscribed" => true,
          "updatedAt" => a_kind_of(Integer)
        }
      )
    end
  end

  describe ".opt_out" do
    before do
      Hubspot.configure(hapikey: ENV["POST_HUBSPOT_HAPI_KEY"])
    end

    let!(:opt_out) do
      VCR.use_cassette("subscription_opt_out_example") do
        Hubspot::Subscription.opt_out(email: "john@doe.com", type_id: 8398069)
      end
    end

    it "succeed" do
      expect(opt_out["success"]).to be_truthy
    end

    it "opt out user" do
      subscription = VCR.use_cassette("subscription_opt_out_status_example") do
        Hubspot::Subscription.status(email: "john@doe.com")
      end

      expect(subscription.subscribed).to be_truthy # user is unsubscribed only from one type of emails
      expect(subscription.marked_as_spam).to be_falsy
      expect(subscription.bounced).to be_truthy
      expect(subscription.status).to eq "subscribed" # user is unsubscribed only from one type of emails
      expect(subscription.subscription_statuses).to include({
        "id" =>  a_kind_of(Integer),
        "optState" => "NOT_OPTED",
        "subscribed" => true,
        "updatedAt" => a_kind_of(Integer)
      })
    end
  end
end
