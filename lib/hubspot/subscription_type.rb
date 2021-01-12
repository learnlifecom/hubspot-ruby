module Hubspot
  class SubscriptionType
    SUBSCRIPTIONS_PATH = '/email/public/v1/subscriptions'

    attr_reader :active
    attr_reader :portal_id
    attr_reader :description
    attr_reader :id
    attr_reader :name

    def initialize(response_hash)
      @active       = response_hash['active']
      @portal_id    = response_hash['portalId']
      @description  = response_hash['description']
      @id           = response_hash['id']
      @name         = response_hash['name']
    end

    class << self
      def all
        response = Hubspot::Connection.get_json(SUBSCRIPTIONS_PATH, {}).fetch('subscriptionDefinitions')
        response.map do  |item_hash|
          new(item_hash)
        end
      end
    end
  end
end
