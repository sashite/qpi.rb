# frozen_string_literal: true

require_relative "qpi/identifier"

module Sashite
  # QPI (Qualified Piece Identifier) implementation for Ruby
  #
  # Provides a rule-agnostic format for identifying game pieces in abstract strategy board games
  # by combining Style Identifier Notation (SIN) and Piece Identifier Notation (PIN) primitives
  # with a colon separator. This combination enables complete piece identification across different
  # game styles and contexts.
  #
  # ## Concept
  #
  # QPI addresses the fundamental need to uniquely identify game pieces across different style
  # systems while maintaining complete attribute information. By combining SIN and PIN primitives,
  # QPI provides explicit representation of all four fundamental piece attributes from the
  # Sashité Protocol.
  #
  # ## Four Fundamental Attributes
  #
  # QPI represents all four piece attributes through primitive combination:
  # - **Family**: Style identification from SIN component
  # - **Type**: Piece type from PIN component
  # - **Side**: Player assignment from both components (must be consistent)
  # - **State**: Piece state from PIN component
  #
  # ## Format Structure
  #
  # A QPI identifier consists of two primitive components separated by a colon:
  # - **SIN component**: Style identification with player assignment
  # - **PIN component**: Piece identification with type, side, and state
  # - **Separator**: Colon (:) provides clear delimitation
  #
  # The components must maintain semantic consistency: both SIN and PIN must represent
  # the same player (first or second) through their respective case encodings.
  #
  # ## Semantic Consistency Constraint
  #
  # QPI enforces a critical constraint: the style identified by the SIN component must be
  # associated with the same player as indicated by the PIN component. This ensures that
  # piece ownership and style ownership remain aligned, preventing impossible combinations
  # like a first player style with a second player piece.
  #
  # Examples of semantic consistency:
  # - SIN "C" (first player) + PIN "K" (first player) = Valid
  # - SIN "c" (second player) + PIN "k" (second player) = Valid
  # - SIN "C" (first player) + PIN "k" (second player) = Invalid
  # - SIN "c" (second player) + PIN "K" (first player) = Invalid
  #
  # ## Cross-Style Gaming Support
  #
  # QPI enables cross-style gaming scenarios where different players use different game
  # traditions. The explicit style identification allows pieces from different systems
  # to coexist while maintaining clear attribution to their respective players.
  #
  # ## Format Specification
  #
  # Structure: `<sin>:<pin>`
  #
  # Grammar (BNF):
  #   <qpi> ::= <uppercase-qpi> | <lowercase-qpi>
  #   <uppercase-qpi> ::= <uppercase-letter> ":" <uppercase-pin>
  #   <lowercase-qpi> ::= <lowercase-letter> ":" <lowercase-pin>
  #   <uppercase-pin> ::= ["+" | "-"] <uppercase-letter>
  #   <lowercase-pin> ::= ["+" | "-"] <lowercase-letter>
  #
  # Regular Expression: `/\A([A-Z]:[-+]?[A-Z]|[a-z]:[-+]?[a-z])\z/`
  #
  # ## Attribute Mapping
  #
  # QPI encodes piece attributes through primitive combination:
  #
  # | Piece Attribute | QPI Encoding | Examples |
  # |-----------------|--------------|----------|
  # | **Family** | SIN component | `C:K` = Chess family, `O:K` = Ogi family |
  # | **Type** | PIN letter choice | `C:K` = King, `C:P` = Pawn |
  # | **Side** | Component cases | `C:K` = First player, `c:k` = Second player |
  # | **State** | PIN prefix modifier | `O:+P` = Enhanced, `C:-P` = Diminished |
  #
  # ## System Constraints
  #
  # - **Semantic Consistency**: SIN and PIN components must represent the same player
  # - **Component Validation**: Each component must be valid according to its specification
  # - **Complete Attribution**: All four fundamental piece attributes explicitly represented
  # - **Cross-Style Support**: Enables multi-tradition gaming environments
  #
  # ## Examples
  #
  # ### Single-Style Games
  #
  #   # Chess (both players use Chess style)
  #   white_king = Sashite::Qpi.parse("C:K")     # Chess king, first player
  #   black_king = Sashite::Qpi.parse("c:k")     # Chess king, second player
  #
  #   # Ogi (both players use Ogi style)
  #   sente_king = Sashite::Qpi.parse("O:K")     # Ogi king, first player (sente)
  #   gote_rook  = Sashite::Qpi.parse("o:+r")    # Ogi promoted rook, second player (gote)
  #
  # ### Cross-Style Games
  #
  #   # Chess vs. Ogi match
  #   chess_player = Sashite::Qpi.parse("C:K")   # First player uses Chess
  #   ogi_player   = Sashite::Qpi.parse("o:k")   # Second player uses Ogi
  #
  #   # Verify cross-style scenario
  #   chess_player.cross_family?(ogi_player)   # => true
  #
  # ### Attribute Access and Manipulation
  #
  #   identifier = Sashite::Qpi.parse("O:+R")
  #
  #   # Four fundamental attributes
  #   identifier.family                           # => :O
  #   identifier.type                             # => :R
  #   identifier.side                             # => :first
  #   identifier.state                            # => :enhanced
  #
  #   # Component extraction
  #   identifier.to_sin                           # => "O"
  #   identifier.to_pin                           # => "+R"
  #
  #   # Immutable transformations
  #   flipped = identifier.flip                   # => "o:+r"
  #   different_type = identifier.with_type(:Q)   # => "O:+Q"
  #   different_family = identifier.with_family(:C) # => "C:+R"
  #
  # ## Design Properties
  #
  # - **Rule-agnostic**: Independent of specific game mechanics
  # - **Complete identification**: Explicit representation of all four piece attributes
  # - **Cross-style support**: Enables multi-tradition gaming environments
  # - **Semantic validation**: Ensures consistency between style and piece ownership
  # - **Primitive foundation**: Built from foundational SIN and PIN building blocks
  # - **Extension-ready**: Can be enhanced by human-readable naming systems
  # - **Context-flexible**: Adaptable to various identification needs
  # - **Immutable**: All instances are frozen and transformations return new objects
  # - **Functional**: Pure functions with no side effects
  #
  # @see https://sashite.dev/specs/qpi/1.0.0/ QPI Specification v1.0.0
  # @see https://sashite.dev/specs/qpi/1.0.0/examples/ QPI Examples
  # @see https://sashite.dev/specs/sin/1.0.0/ Style Identifier Notation (SIN)
  # @see https://sashite.dev/specs/pin/1.0.0/ Piece Identifier Notation (PIN)
  module Qpi
    # Check if a string is a valid QPI notation
    #
    # Validates the string format and semantic consistency between SIN and PIN components.
    # Both components must be individually valid and represent the same player through
    # their respective case encodings.
    #
    # @param qpi_string [String] the string to validate
    # @return [Boolean] true if valid QPI, false otherwise
    #
    # @example Validate various QPI formats
    #   Sashite::Qpi.valid?("C:K")      # => true (Chess king, first player)
    #   Sashite::Qpi.valid?("c:k")      # => true (Chess king, second player)
    #   Sashite::Qpi.valid?("O:+P")     # => true (Ogi enhanced pawn, first player)
    #   Sashite::Qpi.valid?("o:-r")     # => true (Ogi diminished rook, second player)
    #   Sashite::Qpi.valid?("C:k")      # => false (semantic mismatch: first player style, second player piece)
    #   Sashite::Qpi.valid?("c:K")      # => false (semantic mismatch: second player style, first player piece)
    #   Sashite::Qpi.valid?("CHESS:K")  # => false (multi-character SIN component)
    #   Sashite::Qpi.valid?("C")        # => false (missing PIN component)
    def self.valid?(qpi_string)
      Identifier.valid?(qpi_string)
    end

    # Parse a QPI string into an Identifier object
    #
    # Creates a new QPI identifier by parsing the string into SIN and PIN components,
    # validating each component, and ensuring semantic consistency between them.
    #
    # @param qpi_string [String] QPI notation string (format: sin:pin)
    # @return [Qpi::Identifier] parsed identifier object with family, type, side, and state attributes
    # @raise [ArgumentError] if the QPI string is invalid or semantically inconsistent
    #
    # @example Parse different QPI formats with complete attribute access
    #   Sashite::Qpi.parse("C:K")   # => #<Qpi::Identifier family=:C type=:K side=:first state=:normal>
    #   Sashite::Qpi.parse("c:k")   # => #<Qpi::Identifier family=:C type=:K side=:second state=:normal>
    #   Sashite::Qpi.parse("O:+R")  # => #<Qpi::Identifier family=:O type=:R side=:first state=:enhanced>
    #   Sashite::Qpi.parse("x:-s")  # => #<Qpi::Identifier family=:X type=:S side=:second state=:diminished>
    #
    # @example Traditional game styles
    #   chess_king   = Sashite::Qpi.parse("C:K")  # Chess king, first player
    #   ogi_rook     = Sashite::Qpi.parse("o:+r") # Ogi promoted rook, second player
    #   xiongqi_king = Sashite::Qpi.parse("X:K")  # Xiongqi king, first player
    def self.parse(qpi_string)
      Identifier.parse(qpi_string)
    end

    # Create a new identifier instance with explicit parameters
    #
    # Constructs a QPI identifier by directly specifying all four fundamental attributes.
    # This method provides parameter-based construction as an alternative to string parsing,
    # enabling immediate validation and clearer API usage.
    #
    # @param family [Symbol] style family identifier (single ASCII letter as symbol)
    # @param type [Symbol] piece type (:A to :Z)
    # @param side [Symbol] player side (:first or :second)
    # @param state [Symbol] piece state (:normal, :enhanced, or :diminished)
    # @return [Qpi::Identifier] new immutable identifier instance
    # @raise [ArgumentError] if parameters are invalid or semantically inconsistent
    #
    # @example Create identifiers with explicit parameters
    #   Sashite::Qpi.identifier(:C, :K, :first, :normal)     # => "C:K"
    #   Sashite::Qpi.identifier(:c, :K, :second, :normal)    # => "c:k"
    #   Sashite::Qpi.identifier(:O, :R, :first, :enhanced)   # => "O:+R"
    #   Sashite::Qpi.identifier(:x, :S, :second, :diminished) # => "x:-s"
    #
    # @example Cross-style game setup
    #   chess_player = Sashite::Qpi.identifier(:C, :K, :first, :normal)   # Chess king, first player
    #   ogi_player   = Sashite::Qpi.identifier(:o, :K, :second, :normal)  # Ogi king, second player
    #
    #   chess_player.cross_family?(ogi_player)  # => true (different families)
    #   chess_player.same_type?(ogi_player)     # => true (both kings)
    #   chess_player.same_side?(ogi_player)     # => false (different players)
    def self.identifier(family, type, side, state = Pin::Identifier::NORMAL_STATE)
      Identifier.new(family, type, side, state)
    end
  end
end
