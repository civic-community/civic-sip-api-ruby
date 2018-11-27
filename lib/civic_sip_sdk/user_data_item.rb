# frozen_string_literal: true

module CivicSIPSdk
  class UserDataItem
    attr_reader :label, :value, :is_valid, :is_owner

    # Creates an instance of UserDataItem.
    #
    # @param label [String] Descriptive value identifier.
    # @param value [String] Item value of requested user data.
    # @param is_valid [String] Indicates whether or not the data is still considered valid on the blockchain.
    # @param is_owner [String] Civic SIP service challenges the user during scope request approval to ensure
    #   the user is in control of the private key originally used in the issuance of the data attestation.
    def initialize(label:, value:, is_valid:, is_owner:)
      @label = label
      @value = value
      @is_valid = is_valid
      @is_owner = is_owner
    end
  end
end
