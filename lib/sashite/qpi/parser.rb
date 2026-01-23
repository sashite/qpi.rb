# frozen_string_literal: true

require "sashite/sin"
require "sashite/pin"

require_relative "constants"
require_relative "errors"

module Sashite
  module Qpi
    # Parser for QPI (Qualified Piece Identifier) strings.
    #
    # This parser splits the QPI string on the colon separator and delegates
    # parsing of each component to the SIN and PIN libraries.
    #
    # @example
    #   Parser.parse("C:K")   # => { sin: <Sin::Identifier>, pin: <Pin::Identifier> }
    #   Parser.parse("s:+r^") # => { sin: <Sin::Identifier>, pin: <Pin::Identifier> }
    #
    # @see https://sashite.dev/specs/qpi/1.0.0/
    module Parser
      # Parses a QPI string into its components.
      #
      # @param input [String] The QPI string to parse
      # @return [Hash] A hash with :sin and :pin keys containing Identifier instances
      # @raise [Errors::Argument] If the input is not a valid QPI string
      def self.parse(input)
        validate_input_type(input)
        validate_not_empty(input)

        sin_string, pin_string = split_components(input)

        sin = parse_sin(sin_string)
        pin = parse_pin(pin_string)

        { sin: sin, pin: pin }
      end

      # Validates a QPI string without raising an exception.
      #
      # @param input [String] The QPI string to validate
      # @return [Boolean] true if valid, false otherwise
      def self.valid?(input)
        return false unless ::String === input

        parse(input)
        true
      rescue Errors::Argument
        false
      end

      class << self
        private

        # Validates that input is a String.
        #
        # @param input [Object] The input to validate
        # @raise [Errors::Argument] If input is not a String
        def validate_input_type(input)
          return if ::String === input

          raise Errors::Argument, Errors::Argument::Messages::EMPTY_INPUT
        end

        # Validates that input is not empty.
        #
        # @param input [String] The input to validate
        # @raise [Errors::Argument] If input is empty
        def validate_not_empty(input)
          return unless input.empty?

          raise Errors::Argument, Errors::Argument::Messages::EMPTY_INPUT
        end

        # Splits the input into SIN and PIN components.
        #
        # @param input [String] The QPI string to split
        # @return [Array<String>] An array with [sin_string, pin_string]
        # @raise [Errors::Argument] If the separator is missing or components are empty
        def split_components(input)
          unless input.include?(Constants::SEPARATOR)
            raise Errors::Argument, Errors::Argument::Messages::MISSING_SEPARATOR
          end

          sin_string, pin_string = input.split(Constants::SEPARATOR, 2)

          if sin_string.nil? || sin_string.empty?
            raise Errors::Argument, Errors::Argument::Messages::MISSING_SIN
          end

          if pin_string.nil? || pin_string.empty?
            raise Errors::Argument, Errors::Argument::Messages::MISSING_PIN
          end

          [sin_string, pin_string]
        end

        # Parses the SIN component.
        #
        # @param sin_string [String] The SIN string to parse
        # @return [Sashite::Sin::Identifier] The parsed SIN identifier
        # @raise [Errors::Argument] If the SIN is invalid
        def parse_sin(sin_string)
          Sashite::Sin.parse(sin_string)
        rescue ::ArgumentError => e
          raise Errors::Argument, "#{Errors::Argument::Messages::INVALID_SIN}: #{e.message}"
        end

        # Parses the PIN component.
        #
        # @param pin_string [String] The PIN string to parse
        # @return [Sashite::Pin::Identifier] The parsed PIN identifier
        # @raise [Errors::Argument] If the PIN is invalid
        def parse_pin(pin_string)
          Sashite::Pin.parse(pin_string)
        rescue ::ArgumentError => e
          raise Errors::Argument, "#{Errors::Argument::Messages::INVALID_PIN}: #{e.message}"
        end
      end
    end
  end
end
