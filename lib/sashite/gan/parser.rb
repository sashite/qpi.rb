# frozen_string_literal: true

require_relative 'error'
require_relative 'piece'

module Sashite
  module GAN
    # The notation parser.
    module Parser
      def self.call(arg)
        raise Error::String, "Invalid: #{arg.inspect}" unless valid?(arg)

        style, abbr = arg.split(SEPARATOR_CHAR)

        Piece.new(
          abbr.delete('-+'),
          is_king: abbr.include?('-'),
          is_promoted: abbr.include?('+'),
          is_topside: style.downcase.eql?(style),
          style: style
        )
      end

      def self.valid?(arg)
        raise ::TypeError, arg.class.inspect unless arg.is_a?(::String)

        arg.match?(/\A([a-z_]+:\+?-?[a-z]{1,2}|[A-Z_]+:\+?-?[A-Z]{1,2})\z/)
      end
    end
  end
end
