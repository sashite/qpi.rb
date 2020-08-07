# frozen_string_literal: true

module Sashite
  module GAN
    # A piece abstraction.
    class Piece
      # The abbreviation of the piece.
      #
      # @!attribute [r] abbr
      #   @return [String] The abbreviation of the piece.
      attr_reader :abbr

      # The piece's style.
      #
      # @!attribute [r] style
      #   @return [String] The piece's style.
      attr_reader :style

      # Initialize a piece.
      #
      # @param type [String] The type of the piece.
      # @param is_king [Boolean] Is it a King (or a Xiangqi General),
      #   so it could be checkmated?
      # @param is_promoted [Boolean] Is it promoted?
      # @param is_topside [Boolean] Is it owned by top-side player?
      # @param style [String] The piece's style.
      def initialize(type, is_king:, is_promoted:, is_topside:, style:)
        @abbr = Abbr.new(type, is_king: is_king, is_promoted: is_promoted)
        @is_topside = Boolean(is_topside)
        @style = StyleString(style)

        freeze
      end

      def king?
        abbr.king?
      end

      # Is it owned by top-side player?
      #
      # @return [Boolean] Returns `true` if the top-side player own the piece,
      #   `false` otherwise.
      def topside?
        @is_topside
      end

      # Is it owned by bottom-side player?
      #
      # @return [Boolean] Returns `true` if the bottom-side player own the
      #   piece, `false` otherwise.
      def bottomside?
        !topside?
      end

      # @see https://developer.sashite.com/specs/general-actor-notation
      # @return [String] The notation of the piece.
      def to_s
        topside? ? raw.downcase : raw.upcase
      end

      def inspect
        to_s
      end

      # @return [Piece] The top-side side version of the piece.
      def topside
        topside? ? self : oppositeside
      end

      # @return [Piece] The bottom-side side version of the piece.
      def bottomside
        topside? ? oppositeside : self
      end

      # @return [Piece] The opposite side version of the piece.
      def oppositeside
        self.class.new(abbr.type,
          is_king: abbr.king?,
          is_promoted: abbr.promoted?,
          is_topside: !topside?,
          style: style
        )
      end

      # @return [Piece] The promoted version of the piece.
      def promote
        self.class.new(abbr.type,
          is_king: abbr.king?,
          is_promoted: true,
          is_topside: topside?,
          style: style
        )
      end

      # @return [Piece] The unpromoted version of the piece.
      def unpromote
        self.class.new(abbr.type,
          is_king: abbr.king?,
          is_promoted: false,
          is_topside: topside?,
          style: style
        )
      end

      def ==(other)
        other.to_s == to_s
      end

      def eql?(other)
        self == other
      end

      private

      # @return [String] The style and the abbreviation of the piece (without
      #   case).
      def raw
        params.join(SEPARATOR_CHAR)
      end

      # @return [Array] The style and the abbreviation of the piece.
      def params
        [style, abbr]
      end

      # rubocop:disable Naming/MethodName

      # Ensures `arg` is a boolean, and returns it.  Otherwise, raises a
      #   `TypeError`.
      def Boolean(arg)
        raise ::TypeError, arg.class.inspect unless [false, true].include?(arg)

        arg
      end

      # Ensures `arg` is a style, and returns it.  Otherwise, raises an error.
      def StyleString(arg)
        raise ::TypeError, arg.class.inspect unless arg.is_a?(::String)
        raise Error::Style, arg.inspect unless arg.match?(/\A[a-z_]+\z/i)

        arg
      end

      # rubocop:enable Naming/MethodName
    end
  end
end

require_relative 'abbr'
require_relative 'error'
