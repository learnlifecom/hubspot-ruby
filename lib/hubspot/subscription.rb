module Hubspot
  class Subscription
    SUBSCRIPTIONS_PATH = '/email/public/v1/subscriptions'
    TIMELINE_PATH      = '/email/public/v1/subscriptions/timeline'
    SUBSCRIPTION_PATH  = '/email/public/v1/subscriptions/:email_address'

    attr_reader :subscribed
    attr_reader :marked_as_spam
    attr_reader :bounced
    attr_reader :status
    attr_reader :subscription_statuses

    def initialize(response_hash)
      @subscribed     = response_hash['subscribed']
      @marked_as_spam = response_hash['markedAsSpam']
      @bounced        = response_hash['bounced']
      @status         = response_hash['status']
      @subscription_statuses  = response_hash['subscriptionStatuses']
    end

    class << self
      def status(email:)
        response = Hubspot::Connection.get_json(SUBSCRIPTION_PATH, {email_address: email})
        new(response)
      end

      def opt_in(email:, type_id:, legal_explanation: "")
        response = Hubspot::Connection.put_json(SUBSCRIPTION_PATH,
          params: { email_address: email },
          body: {
            subscriptionStatuses: [
              {
                id: type_id,
                subscribed: true,
                optState: "OPT_IN",
                legalBasis: "LEGITIMATE_INTEREST_CLIENT",
                legalBasisExplanation: legal_explanation
              }
            ],
            portalSubscriptionLegalBasis: "LEGITIMATE_INTEREST_CLIENT",
            portalSubscriptionLegalBasisExplanation: legal_explanation
          }
        )
      end

      def opt_out(email:, type_id:)
        response = Hubspot::Connection.put_json(SUBSCRIPTION_PATH,
          params: { email_address: email },
          body: {
            subscriptionStatuses: [
              {
                id: type_id,
                subscribed: false,
                optState: "OPT_OUT",
              }
            ],
          }
        )
      end

      # https://community.hubspot.com/t5/APIs-Integrations/How-to-generate-the-unsubscribe-link-for-a-user/m-p/233820
      def preferences_url(email:, host: ENV.fetch("HUBSPOT_EMAIL_HOST", "") )
        encoded_email = Base64.encode64("{\"ea\": \"#{email}\"}")
        "#{host}/hs/manage-preferences/unsubscribe?d=#{encoded_email}&v=2"
      end
    end
  end
end
