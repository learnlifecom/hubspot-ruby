require 'spec_helper'

describe Hubspot::Subscription do
  describe ".status" do
    before do
      Hubspot.configure(hapikey: "demo")
    end
    let(:subscription) do
      VCR.use_cassette("subscription_status_example") do
        Hubspot::Subscription.status(email: "john@doetest.com")
      end
    end

    it "populates properties" do
      expect(subscription.subscribed).to be_truthy
      expect(subscription.marked_as_spam).to be_falsy
      expect(subscription.bounced).to be_falsy
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
        Hubspot::Subscription.opt_in(email: "john@doetest.com", type_id: 8398069, legal_explanation: 'Explanation')
      end
    end

    it "succeed" do
      expect(opt_in["success"]).to be_truthy
    end

    it "opt in user" do
      subscription = VCR.use_cassette("subscription_opt_in_status_example") do
        Hubspot::Subscription.status(email: "john@doetest.com")
      end

      expect(subscription.subscribed).to be_truthy
      expect(subscription.marked_as_spam).to be_falsy
      expect(subscription.bounced).to be_falsy
      expect(subscription.status).to eq "subscribed"
      expect(subscription.subscription_statuses).to include(
        {
          "id" => a_kind_of(Integer),
          "legalBasis" => "LEGITIMATE_INTEREST_CLIENT",
          "legalBasisExplanation" => "Explanation",
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
        Hubspot::Subscription.opt_out(email: "john@doetest.com", type_id: 8398069)
      end
    end

    it "succeed" do
      expect(opt_out["success"]).to be_truthy
    end

    it "opt out user" do
      subscription = VCR.use_cassette("subscription_opt_out_status_example") do
        Hubspot::Subscription.status(email: "john@doetest.com")
      end

      expect(subscription.subscribed).to be_truthy # user is unsubscribed only from one type of emails
      expect(subscription.marked_as_spam).to be_falsy
      expect(subscription.bounced).to be_falsy
      expect(subscription.status).to eq "subscribed" # user is unsubscribed only from one type of emails
      expect(subscription.subscription_statuses).to include({
        "id" =>  a_kind_of(Integer),
        "optState" => "OPT_OUT",
        "subscribed" => false,
        "updatedAt" => a_kind_of(Integer)
      })
    end
  end

  describe ".unsubscribe_all" do
    before do
      Hubspot.configure(hapikey: ENV["POST_HUBSPOT_HAPI_KEY"])
    end

    let!(:opt_out) do
      VCR.use_cassette("subscription_unsubscribe_all_example") do
        Hubspot::Subscription.unsubscribe_all(email: "john@doetest2.com")
      end
    end

    it "succeed" do
      expect(opt_out["success"]).to be_truthy
    end

    it "opt out user" do
      subscription = VCR.use_cassette("subscription_unsubscribe_all_status_example") do
        Hubspot::Subscription.status(email: "john@doetest2.com")
      end

      expect(subscription.subscribed).to be_falsy # user is unsubscribed only from one type of emails
      expect(subscription.marked_as_spam).to be_falsy
      expect(subscription.bounced).to be_falsy
      expect(subscription.status).to eq "unsubscribed" # user is unsubscribed only from one type of emails
      expect(subscription.subscription_statuses).to be_empty
    end
  end

  describe ".preferences_url" do
    it "encodes email to d param" do
      encoded = Base64.encode64("{\"ea\": \"test@demo.com\"}")
      url = described_class.preferences_url(email: 'test@demo.com')
      expect(url).to include("/hs/manage-preferences/unsubscribe?d=#{encoded}&v=2")
    end

    it "allows to pass custom host" do
      url = described_class.preferences_url(email: 'test@demo.com', host: 'https://testhost.com')
      expect(url).to include("https://testhost.com")
    end
  end
end
