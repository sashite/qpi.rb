# frozen_string_literal: true

require "pnn"

module Sashite
  module Gan
    # Validates GAN strings
    class Validator
      # GAN regex pattern for validation
      PATTERN = /\A([A-Z]+:[-+]?[A-Z][']?|[a-z]+:[-+]?[a-z][']?)\z/

      # Validates if the given string is a valid GAN string
      #
      # @param gan_string [String] The GAN string to validate
      # @return [Boolean] True if the string is a valid GAN string
      def self.valid?(gan_string)
        return false unless gan_string.is_a?(String)

        PATTERN.match?(gan_string)
      end
    end
  end
end
