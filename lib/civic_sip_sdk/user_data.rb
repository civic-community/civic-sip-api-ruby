# frozen_string_literal: true

require 'civic_sip_sdk/user_data_item'

module CivicSIPSdk
  class UserData
    attr_reader :user_id, :data_items

    # Creates a UserData insteance, which creates a list of UserDataItem instances from
    # +data_items+.
    #
    # @param user_id [String] user id
    # @param data_items [List] a list of Hash that contains the key-value pairs
    #   for instantiating CivicSIPSdk::UserDataItem instances
    def initialize(user_id:, data_items:)
      @user_id = user_id
      @data_items = data_items
      @indexed_data_items = index_data_items
    end

    # Returns a +UserDataItem+ instance by matching the value of +label+, or +nil+
    # if the label doesn't exist
    def by_label(label:)
      @indexed_data_items.fetch(label, nil)
    end

    private

    def index_data_items
      @data_items.each_with_object({}) do |data_item, memo|
        memo[data_item['label']] = UserDataItem.new(
          label: data_item['label'],
          value: data_item['value'],
          is_valid: data_item['isValid'],
          is_owner: data_item['isOwner']
        )
      end
    end
  end
end
