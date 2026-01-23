# frozen_string_literal: true

require_relative "argument/messages"

module Sashite
  module Qpi
    module Errors
      # Error raised when QPI parsing or validation fails.
      #
      # @example
      #   raise Argument, Argument::Messages::EMPTY_INPUT
      class Argument < ::ArgumentError
      end
    end
  end
end
