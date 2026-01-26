# frozen_string_literal: true

require_relative "qpi/constants"
require_relative "qpi/errors"
require_relative "qpi/identifier"
require_relative "qpi/parser"

module Sashite
  # QPI (Qualified Piece Identifier) implementation for Ruby.
  #
  # QPI provides complete piece identification by combining two primitive notations:
  # - SIN (Style Identifier Notation) for Piece Style
  # - PIN (Piece Identifier Notation) for Piece Name, Side, State, and Terminal Status
  #
  # == Format
  #
  #   <sin>:<pin>
  #
  # - *SIN*: Single ASCII letter encoding Piece Style and a side tag
  # - *PIN*: Piece identifier with optional state modifier and terminal marker
  #
  # == Piece Identity Attributes
  #
  # A QPI token encodes complete Piece Identity:
  #
  # - *Piece Style* → SIN letter (case-insensitive identity)
  # - *Piece Name* → PIN letter (case-insensitive identity)
  # - *Piece Side* → PIN letter case (uppercase = first, lowercase = second)
  # - *Piece State* → PIN modifier (+/-)
  # - *Terminal Status* → PIN marker (^)
  #
  # == Native/Derived Relationship
  #
  # QPI defines a deterministic relationship based on case comparison:
  #
  # - *Native*: SIN case matches PIN case (sin.side == pin.side)
  # - *Derived*: SIN case differs from PIN case (sin.side != pin.side)
  #
  # == Examples
  #
  #   qpi = Sashite::Qpi.parse("C:K^")
  #   qpi.sin.abbr       # => :C
  #   qpi.pin.abbr       # => :K
  #   qpi.pin.side       # => :first
  #   qpi.pin.state      # => :normal
  #   qpi.pin.terminal?  # => true
  #   qpi.native?        # => true
  #
  #   qpi = Sashite::Qpi.parse("C:k")
  #   qpi.derived?  # => true
  #   qpi.native.to_s  # => "C:K"
  #
  #   Sashite::Qpi.valid?("C:K^")     # => true
  #   Sashite::Qpi.valid?("invalid")  # => false
  #
  # @see https://sashite.dev/specs/qpi/1.0.0/
  module Qpi
    # Parses a QPI string into an Identifier.
    #
    # @param string [String] The QPI string to parse
    # @return [Identifier] A new Identifier instance
    # @raise [Errors::Argument] If the string is not a valid QPI
    #
    # @example
    #   Sashite::Qpi.parse("C:K")
    #   # => #<Sashite::Qpi::Identifier C:K>
    #
    #   Sashite::Qpi.parse("s:+r^")
    #   # => #<Sashite::Qpi::Identifier s:+r^>
    #
    #   Sashite::Qpi.parse("invalid")
    #   # => raises Errors::Argument
    def self.parse(string)
      components = Parser.parse(string)

      Identifier.new(components[:sin], components[:pin])
    end

    # Checks if a string is a valid QPI notation.
    #
    # @param string [String] The string to validate
    # @return [Boolean] true if valid, false otherwise
    #
    # @example
    #   Sashite::Qpi.valid?("C:K")       # => true
    #   Sashite::Qpi.valid?("s:+r^")     # => true
    #   Sashite::Qpi.valid?("invalid")   # => false
    def self.valid?(string)
      Parser.valid?(string)
    end
  end
end
