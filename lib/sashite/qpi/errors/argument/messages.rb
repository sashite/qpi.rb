# frozen_string_literal: true

module Sashite
  module Qpi
    module Errors
      class Argument < ::ArgumentError
        # Centralized error messages for QPI parsing and validation.
        #
        # @example
        #   raise Errors::Argument, Messages::EMPTY_INPUT
        module Messages
          # Parsing errors
          EMPTY_INPUT = "empty input"
          MISSING_SEPARATOR = "missing colon separator"
          MISSING_SIN = "missing SIN component"
          MISSING_PIN = "missing PIN component"
          INVALID_SIN = "invalid SIN component"
          INVALID_PIN = "invalid PIN component"
        end
      end
    end
  end
end
