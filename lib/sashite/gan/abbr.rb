# frozen_string_literal: true

module Sashite
  module GAN
    # The piece's abbreviation.
    class Abbr
      # The piece's type.
      #
      # @!attribute [r] type
      #   @return [String] The type of the piece.
      attr_reader :type

      def initialize(type, is_promoted:, is_king:)
        @type = TypeString(type)
        @is_promoted = Boolean(is_promoted)
        @is_king = Boolean(is_king)

        freeze
      end

      # @return [Boolean] Is the piece a king?
      def king?
        @is_king
      end

      # @return [Boolean] Is the piece promoted?
      def promoted?
        @is_promoted
      end

      # @return [String] The abbreviation of the piece.
      def to_s
        str = type
        str = "-#{str}" if king?
        str = "+#{str}" if promoted?
        str
      end

      def inspect
        to_s
      end

      private

      # rubocop:disable Naming/MethodName

      # Ensures `arg` is a boolean, and returns it.  Otherwise, raises a
      #   `TypeError`.
      def Boolean(arg)
        raise ::TypeError, arg.class.inspect unless [false, true].include?(arg)

        arg
      end

      # Ensures `arg` is a type, and returns it.  Otherwise, raises an error.
      def TypeString(arg)
        raise ::TypeError, arg.class.inspect unless arg.is_a?(::String)
        raise Error::Type, arg.inspect unless arg.match?(/\A[a-z]{1,2}\z/i)

        arg
      end

      # rubocop:enable Naming/MethodName
    end
  end
end

require_relative 'error'
