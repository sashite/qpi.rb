# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Qpi (Qualified Piece Identifier)
#
# Tests the QPI implementation for Ruby, focusing on the modern object-oriented API
# with the Identifier class combining SIN and PIN primitives conforming to QPI v1.0.0 specification.
# Updated for strict parameter validation consistent with SIN and PIN primitives.
#
# This test assumes the existence of:
# - lib/sashite-qpi.rb

require_relative "lib/sashite-qpi"
require "set"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Sashite::Qpi (Qualified Piece Identifier) v1.0.0"
puts

# Test basic validation (module level)
run_test("Module QPI validation accepts valid notations") do
  valid_qpis = [
    "C:K", "C:Q", "C:R", "C:B", "C:N", "C:P",
    "c:k", "c:q", "c:r", "c:b", "c:n", "c:p",
    "S:K", "S:G", "S:S", "S:L", "S:N", "S:P",
    "s:k", "s:g", "s:s", "s:l", "s:n", "s:p",
    "C:+K", "C:+Q", "C:+R", "C:+B", "C:+N", "C:+P",
    "c:+k", "c:+q", "c:+r", "c:+b", "c:+n", "c:+p",
    "S:-K", "S:-G", "S:-S", "S:-L", "S:-N", "S:-P",
    "s:-k", "s:-g", "s:-s", "s:-l", "s:-n", "s:-p",
    "A:A", "Z:Z", "a:a", "z:z"
  ]

  valid_qpis.each do |qpi|
    raise "#{qpi.inspect} should be valid" unless Sashite::Qpi.valid?(qpi)
  end
end

run_test("Module QPI validation rejects invalid notations") do
  invalid_qpis = [
    # Missing separator
    "", "C", "K", "CK", "Chess", "CHESS:KING",

    # Invalid format
    "C:", ":K", "C::", "::K", "C::K", "C:K:",

    # Multiple separators
    "C:K:R", "C:K:+", "Chess:King:State",

    # Semantic mismatches (syntactically valid but semantically incorrect)
    "C:k", "c:K", "S:p", "s:P", "C:+k", "c:+K", "S:-p", "s:-P",

    # Invalid SIN components
    "1:K", "Chess:K", "CC:K", "++:K", "--:K", " C:K", "C :K",

    # Invalid PIN components
    "C:1", "C:King", "C:KK", "C:++K", "C:--K", "C:K+", "C:K-", "C: K", "C:K ",

    # Invalid characters
    "Ç:K", "C:Ķ", "α:K", "C:β", "♕:K", "C:♔", "象:K", "C:将",

    # Whitespace issues
    " C:K", "C:K ", " C:K ", "C: K", "C :K", "\tC:K", "C:K\t", "\nC:K", "C:K\n"
  ]

  invalid_qpis.each do |qpi|
    raise "#{qpi.inspect} should be invalid" if Sashite::Qpi.valid?(qpi)
  end
end

run_test("Module QPI validation handles non-string input") do
  non_strings = [nil, 123, :chess, [], {}, true, false, 1.5]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Qpi.valid?(input)
  end
end

# Test module parse method delegates to Identifier
run_test("Module parse delegates to Identifier class") do
  qpi_string = "C:K"
  identifier = Sashite::Qpi.parse(qpi_string)

  raise "parse should return Identifier instance" unless identifier.is_a?(Sashite::Qpi::Identifier)
  raise "identifier should have correct QPI string" unless identifier.to_s == qpi_string
end

# Test module identifier factory method with strict validation
run_test("Module identifier factory method creates correct instances") do
  identifier = Sashite::Qpi.identifier(:C, :K, :first, :normal)

  raise "identifier factory should return Identifier instance" unless identifier.is_a?(Sashite::Qpi::Identifier)
  raise "identifier should have correct family" unless identifier.family == :C
  raise "identifier should have correct type" unless identifier.type == :K
  raise "identifier should have correct side" unless identifier.side == :first
  raise "identifier should have correct state" unless identifier.state == :normal
  raise "identifier should have correct QPI string" unless identifier.to_s == "C:K"
end

# Test strict parameter validation like SIN and PIN
run_test("Identifier strict parameter validation like SIN and PIN") do
  # Valid - uppercase symbols only
  valid_cases = [
    [:C, :K, :first, :normal],
    [:C, :K, :second, :normal],
    [:S, :R, :first, :enhanced],
    [:X, :S, :second, :diminished]
  ]

  valid_cases.each do |family, type, side, state|
    identifier = Sashite::Qpi::Identifier.new(family, type, side, state)
    raise "Valid case should work: #{[family, type, side, state].inspect}" unless identifier.family == family
  end

  # Invalid - lowercase symbols should be rejected for family
  invalid_family_cases = [
    [:c, :K, :first, :normal],    # lowercase family
    [:s, :R, :second, :enhanced], # lowercase family
    [:x, :S, :first, :diminished] # lowercase family
  ]

  invalid_family_cases.each do |family, type, side, state|
    begin
      Sashite::Qpi::Identifier.new(family, type, side, state)
      raise "Should have raised error for lowercase family #{family.inspect}"
    rescue ArgumentError => e
      raise "Error should mention invalid family" unless e.message.include?("Family must be")
    end
  end

  # Invalid - lowercase type should be rejected (delegated to PIN)
  invalid_type_cases = [
    [:C, :k, :first, :normal],    # lowercase type
    [:S, :r, :second, :enhanced], # lowercase type
    [:X, :s, :first, :diminished] # lowercase type
  ]

  invalid_type_cases.each do |family, type, side, state|
    begin
      Sashite::Qpi::Identifier.new(family, type, side, state)
      raise "Should have raised error for lowercase type #{type.inspect}"
    rescue ArgumentError => e
      raise "Error should mention invalid type" unless e.message.include?("Type must be")
    end
  end
end

# Test the Identifier class with primitive combination
run_test("Identifier.parse creates correct instances with all four attributes") do
  test_cases = {
    "C:K" => { family: :C, type: :K, side: :first, state: :normal },
    "c:k" => { family: :C, type: :K, side: :second, state: :normal },
    "S:+R" => { family: :S, type: :R, side: :first, state: :enhanced },
    "s:+r" => { family: :S, type: :R, side: :second, state: :enhanced },
    "X:-S" => { family: :X, type: :S, side: :first, state: :diminished },
    "x:-s" => { family: :X, type: :S, side: :second, state: :diminished }
  }

  test_cases.each do |qpi_string, expected|
    identifier = Sashite::Qpi.parse(qpi_string)

    raise "#{qpi_string}: wrong family" unless identifier.family == expected[:family]
    raise "#{qpi_string}: wrong type" unless identifier.type == expected[:type]
    raise "#{qpi_string}: wrong side" unless identifier.side == expected[:side]
    raise "#{qpi_string}: wrong state" unless identifier.state == expected[:state]
  end
end

run_test("Identifier constructor with all four parameters") do
  # All test cases must use uppercase symbols only for family and type
  test_cases = [
    [:C, :K, :first, :normal, "C:K"],
    [:C, :K, :second, :normal, "c:k"],    # Note: family stays :C, side determines display case
    [:S, :R, :first, :enhanced, "S:+R"],
    [:S, :R, :second, :enhanced, "s:+r"], # Note: family stays :S, side determines display case
    [:X, :S, :first, :diminished, "X:-S"],
    [:X, :S, :second, :diminished, "x:-s"] # Note: family stays :X, side determines display case
  ]

  test_cases.each do |family, type, side, state, expected_qpi|
    identifier = Sashite::Qpi::Identifier.new(family, type, side, state)

    raise "family should always be uppercase symbol #{family}" unless identifier.family == family
    raise "type should be #{type}" unless identifier.type == type
    raise "side should be #{side}" unless identifier.side == side
    raise "state should be #{state}" unless identifier.state == state
    raise "QPI string should be #{expected_qpi}" unless identifier.to_s == expected_qpi
  end
end

run_test("Identifier to_s returns correct QPI string") do
  test_cases = [
    [:C, :K, :first, :normal, "C:K"],
    [:C, :K, :second, :normal, "c:k"],
    [:S, :R, :first, :enhanced, "S:+R"],
    [:X, :S, :second, :diminished, "x:-s"]
  ]

  test_cases.each do |family, type, side, state, expected|
    identifier = Sashite::Qpi::Identifier.new(family, type, side, state)
    result = identifier.to_s

    raise "#{family}, #{type}, #{side}, #{state} should be #{expected}, got #{result}" unless result == expected
  end
end

run_test("Identifier component access methods") do
  test_cases = [
    ["C:K", "C", "K"],
    ["c:k", "c", "k"],
    ["S:+R", "S", "+R"],
    ["x:-s", "x", "-s"]
  ]

  test_cases.each do |qpi_string, expected_sin, expected_pin|
    identifier = Sashite::Qpi.parse(qpi_string)

    raise "#{qpi_string}: wrong SIN component" unless identifier.to_sin == expected_sin
    raise "#{qpi_string}: wrong PIN component" unless identifier.to_pin == expected_pin
    raise "#{qpi_string}: sin_component should be SIN::Identifier" unless identifier.sin_component.is_a?(Sashite::Sin::Identifier)
    raise "#{qpi_string}: pin_component should be PIN::Identifier" unless identifier.pin_component.is_a?(Sashite::Pin::Identifier)
    raise "#{qpi_string}: to_s should equal sin + ':' + pin" unless identifier.to_s == "#{identifier.to_sin}:#{identifier.to_pin}"
  end
end

run_test("Identifier state mutations return new instances") do
  identifier = Sashite::Qpi::Identifier.new(:C, :K, :first, :normal)

  # Test enhance
  enhanced = identifier.enhance
  raise "enhance should return new instance" if enhanced.equal?(identifier)
  raise "enhanced identifier should be enhanced" unless enhanced.enhanced?
  raise "enhanced identifier state should be :enhanced" unless enhanced.state == :enhanced
  raise "original identifier should be unchanged" unless identifier.state == :normal
  raise "enhanced identifier should have same family, type, side" unless enhanced.family == identifier.family && enhanced.type == identifier.type && enhanced.side == identifier.side

  # Test diminish
  diminished = identifier.diminish
  raise "diminish should return new instance" if diminished.equal?(identifier)
  raise "diminished identifier should be diminished" unless diminished.diminished?
  raise "diminished identifier state should be :diminished" unless diminished.state == :diminished
  raise "original identifier should be unchanged" unless identifier.state == :normal

  # Test normalize
  normalized = enhanced.normalize
  raise "normalize should return new instance" if normalized.equal?(enhanced)
  raise "normalized identifier should be normal" unless normalized.normal?
  raise "original enhanced identifier should be unchanged" unless enhanced.enhanced?
end

run_test("Identifier attribute transformations") do
  identifier = Sashite::Qpi::Identifier.new(:C, :K, :first, :normal)

  # Test with_family
  s_identifier = identifier.with_family(:S)
  raise "with_family should return new instance" if s_identifier.equal?(identifier)
  raise "new identifier should have different family" unless s_identifier.family == :S
  raise "new identifier should have same type, side, state" unless s_identifier.type == identifier.type && s_identifier.side == identifier.side && s_identifier.state == identifier.state

  # Test with_type
  queen = identifier.with_type(:Q)
  raise "with_type should return new instance" if queen.equal?(identifier)
  raise "new identifier should have different type" unless queen.type == :Q
  raise "new identifier should have same family, side, state" unless queen.family == identifier.family && queen.side == identifier.side && queen.state == identifier.state

  # Test with_side
  black_king = identifier.with_side(:second)
  raise "with_side should return new instance" if black_king.equal?(identifier)
  raise "new identifier should have different side" unless black_king.side == :second
  raise "new identifier should have same family, type, state" unless black_king.family == identifier.family && black_king.type == identifier.type && black_king.state == identifier.state
  raise "new identifier should have correct QPI string" unless black_king.to_s == "c:k"

  # Test with_state
  enhanced_king = identifier.with_state(:enhanced)
  raise "with_state should return new instance" if enhanced_king.equal?(identifier)
  raise "new identifier should have different state" unless enhanced_king.state == :enhanced
  raise "new identifier should have same family, type, side" unless enhanced_king.family == identifier.family && enhanced_king.type == identifier.type && enhanced_king.side == identifier.side
end

run_test("Identifier flip transformation") do
  identifier = Sashite::Qpi::Identifier.new(:C, :K, :first, :normal)

  # Test flip
  flipped = identifier.flip
  raise "flip should return new instance" if flipped.equal?(identifier)
  raise "flipped identifier should have opposite side" unless flipped.side == :second
  raise "flipped identifier should have same family, type, state" unless flipped.family == identifier.family && flipped.type == identifier.type && flipped.state == identifier.state
  raise "flipped identifier should have correct QPI string" unless flipped.to_s == "c:k"
  raise "original identifier should be unchanged" unless identifier.side == :first

  # Test flip preserves enhanced state
  enhanced = Sashite::Qpi.parse("S:+R")
  flipped_enhanced = enhanced.flip
  raise "flip should preserve enhanced state" unless flipped_enhanced.enhanced?
  raise "flipped enhanced should have correct QPI string" unless flipped_enhanced.to_s == "s:+r"
end

run_test("Identifier immutability") do
  identifier = Sashite::Qpi::Identifier.new(:C, :K, :first, :enhanced)

  # Test that identifier is frozen
  raise "identifier should be frozen" unless identifier.frozen?

  # Test that mutations don't affect original
  original_string = identifier.to_s
  normalized = identifier.normalize
  flipped = identifier.flip

  raise "original identifier should be unchanged after normalize" unless identifier.to_s == original_string
  raise "original identifier should be unchanged after flip" unless identifier.to_s == original_string
  raise "normalized identifier should be different" unless normalized.to_s == "C:K"
  raise "flipped identifier should be different" unless flipped.to_s == "c:+k"
end

run_test("Identifier equality and hash") do
  identifier1 = Sashite::Qpi::Identifier.new(:C, :K, :first, :normal)
  identifier2 = Sashite::Qpi::Identifier.new(:C, :K, :first, :normal)
  identifier3 = Sashite::Qpi::Identifier.new(:C, :K, :second, :normal)
  identifier4 = Sashite::Qpi::Identifier.new(:S, :K, :first, :normal)
  identifier5 = Sashite::Qpi::Identifier.new(:C, :Q, :first, :normal)
  identifier6 = Sashite::Qpi::Identifier.new(:C, :K, :first, :enhanced)

  # Test equality
  raise "identical identifiers should be equal" unless identifier1 == identifier2
  raise "different side should not be equal" if identifier1 == identifier3
  raise "different family should not be equal" if identifier1 == identifier4
  raise "different type should not be equal" if identifier1 == identifier5
  raise "different state should not be equal" if identifier1 == identifier6

  # Test hash consistency
  raise "equal identifiers should have same hash" unless identifier1.hash == identifier2.hash

  # Test in hash/set
  identifiers_set = Set.new([identifier1, identifier2, identifier3, identifier4, identifier5, identifier6])
  raise "set should contain 5 unique identifiers" unless identifiers_set.size == 5
end

run_test("Identifier family, type, side, and state identification") do
  test_cases = [
    ["C:K", :C, :K, :first, :normal, true, false, true, false, false],
    ["c:k", :C, :K, :second, :normal, false, true, true, false, false],
    ["S:+R", :S, :R, :first, :enhanced, true, false, false, true, false],
    ["x:-s", :X, :S, :second, :diminished, false, true, false, false, true]
  ]

  test_cases.each do |qpi_string, expected_family, expected_type, expected_side, expected_state, is_first, is_second, is_normal, is_enhanced, is_diminished|
    identifier = Sashite::Qpi.parse(qpi_string)

    raise "#{qpi_string}: wrong family" unless identifier.family == expected_family
    raise "#{qpi_string}: wrong type" unless identifier.type == expected_type
    raise "#{qpi_string}: wrong side" unless identifier.side == expected_side
    raise "#{qpi_string}: wrong state" unless identifier.state == expected_state
    raise "#{qpi_string}: wrong first_player?" unless identifier.first_player? == is_first
    raise "#{qpi_string}: wrong second_player?" unless identifier.second_player? == is_second
    raise "#{qpi_string}: wrong normal?" unless identifier.normal? == is_normal
    raise "#{qpi_string}: wrong enhanced?" unless identifier.enhanced? == is_enhanced
    raise "#{qpi_string}: wrong diminished?" unless identifier.diminished? == is_diminished
  end
end

run_test("Identifier comparison methods") do
  c_first = Sashite::Qpi::Identifier.new(:C, :K, :first, :normal)
  c_second = Sashite::Qpi::Identifier.new(:C, :K, :second, :normal)
  s_first = Sashite::Qpi::Identifier.new(:S, :K, :first, :normal)
  s_second = Sashite::Qpi::Identifier.new(:S, :K, :second, :normal)
  c_queen = Sashite::Qpi::Identifier.new(:C, :Q, :first, :normal)
  c_enhanced = Sashite::Qpi::Identifier.new(:C, :K, :first, :enhanced)

  # same_family? tests
  raise "C first and C second should be same family" unless c_first.same_family?(c_second)
  raise "C and S should not be same family" if c_first.same_family?(s_first)

  # cross_family? tests
  raise "C and S should be cross family" unless c_first.cross_family?(s_first)
  raise "C first and C second should not be cross family" if c_first.cross_family?(c_second)

  # same_side? tests
  raise "first player identifiers should be same side" unless c_first.same_side?(s_first)
  raise "different side identifiers should not be same side" if c_first.same_side?(c_second)

  # same_type? tests
  raise "king identifiers should be same type" unless c_first.same_type?(s_first)
  raise "king and queen should not be same type" if c_first.same_type?(c_queen)

  # same_state? tests
  raise "normal identifiers should be same state" unless c_first.same_state?(s_first)
  raise "normal and enhanced should not be same state" if c_first.same_state?(c_enhanced)
end

run_test("Identifier transformation methods return self when appropriate") do
  identifier = Sashite::Qpi::Identifier.new(:C, :K, :first, :normal)
  enhanced = Sashite::Qpi::Identifier.new(:C, :K, :first, :enhanced)
  diminished = Sashite::Qpi::Identifier.new(:C, :K, :first, :diminished)

  # Test with_* methods that should return self
  raise "with_family with same family should return self" unless identifier.with_family(:C).equal?(identifier)
  raise "with_type with same type should return self" unless identifier.with_type(:K).equal?(identifier)
  raise "with_side with same side should return self" unless identifier.with_side(:first).equal?(identifier)
  raise "with_state with same state should return self" unless identifier.with_state(:normal).equal?(identifier)

  # Test state methods that should return self
  raise "normalize on normal should return self" unless identifier.normalize.equal?(identifier)
  raise "enhance on enhanced should return self" unless enhanced.enhance.equal?(enhanced)
  raise "diminish on diminished should return self" unless diminished.diminish.equal?(diminished)
end

run_test("Identifier transformation chains") do
  identifier = Sashite::Qpi::Identifier.new(:C, :K, :first, :normal)

  # Test flip then flip
  flipped = identifier.flip
  back_to_original = flipped.flip
  raise "flip then flip should equal original" unless back_to_original == identifier

  # Test enhance then normalize
  enhanced = identifier.enhance
  back_to_normal = enhanced.normalize
  raise "enhance then normalize should equal original" unless back_to_normal == identifier

  # Test complex chain
  transformed = identifier.flip.enhance.with_type(:Q).with_family(:S)
  expected_final = "s:+q"  # Should end up as enhanced queen in S family, second player

  raise "Chained transformation should work" unless transformed.to_s == expected_final
  raise "Original identifier should be unchanged" unless identifier.to_s == "C:K"
end

run_test("Identifier error handling for invalid parameters") do
  # Invalid families - lowercase symbols rejected
  invalid_families = [:c, :s, :x, nil, "", "Chess", "CC", :chess, :AA, 1, [], {}]

  invalid_families.each do |family|
    begin
      Sashite::Qpi::Identifier.new(family, :K, :first, :normal)
      raise "Should have raised error for invalid family #{family.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid family" unless e.message.include?("Family must be")
    end
  end

  # Invalid types - lowercase symbols rejected (delegated to PIN)
  invalid_types = [:k, :q, :r, :invalid, :"1", :AA, "K", 1, nil]

  invalid_types.each do |type|
    begin
      Sashite::Qpi::Identifier.new(:C, type, :first, :normal)
      raise "Should have raised error for invalid type #{type.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid type" unless e.message.include?("Type must be")
    end
  end

  # Invalid sides (delegated to PIN)
  invalid_sides = [:invalid, :player1, :white, "first", 1, nil]

  invalid_sides.each do |side|
    begin
      Sashite::Qpi::Identifier.new(:C, :K, side, :normal)
      raise "Should have raised error for invalid side #{side.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid side" unless e.message.include?("Side must be")
    end
  end

  # Invalid states (delegated to PIN)
  invalid_states = [:invalid, :promoted, :active, "normal", 1, nil]

  invalid_states.each do |state|
    begin
      Sashite::Qpi::Identifier.new(:C, :K, :first, state)
      raise "Should have raised error for invalid state #{state.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid state" unless e.message.include?("State must be")
    end
  end
end

run_test("Identifier error handling for invalid QPI strings") do
  # Invalid QPI strings
  invalid_qpis = ["", "C", ":K", "C:", "C::", "Chess:King", "C:k", "c:K", nil, 123]

  invalid_qpis.each do |qpi|
    begin
      Sashite::Qpi.parse(qpi)
      raise "Should have raised error for #{qpi.inspect}"
    rescue ArgumentError
      # Expected
    end
  end
end

run_test("Semantic consistency validation") do
  # Test that semantic mismatches are properly detected
  mismatched_cases = [
    ["C", "k"],  # First player style with second player piece
    ["c", "K"],  # Second player style with first player piece
    ["S", "p"],  # First player style with second player piece
    ["s", "P"],  # Second player style with first player piece
    ["X", "+r"], # First player style with second player enhanced piece
    ["x", "+R"]  # Second player style with first player enhanced piece
  ]

  mismatched_cases.each do |sin_part, pin_part|
    qpi_string = "#{sin_part}:#{pin_part}"

    raise "#{qpi_string} should be invalid (semantic mismatch)" if Sashite::Qpi.valid?(qpi_string)

    begin
      Sashite::Qpi.parse(qpi_string)
      raise "Should have raised error for semantic mismatch #{qpi_string}"
    rescue ArgumentError
      # Expected
    end
  end
end

# Test traditional game examples with QPI
run_test("Western Chess pieces with QPI") do
  # Standard pieces
  white_king = Sashite::Qpi.identifier(:C, :K, :first, :normal)
  raise "White king should be first player" unless white_king.first_player?
  raise "White king family should be :C" unless white_king.family == :C
  raise "White king type should be :K" unless white_king.type == :K
  raise "White king should be normal" unless white_king.normal?
  raise "White king QPI should be C:K" unless white_king.to_s == "C:K"

  black_king = white_king.flip
  raise "Black king should be second player" unless black_king.second_player?
  raise "Black king QPI should be c:k" unless black_king.to_s == "c:k"

  # Enhanced state (e.g., castling king)
  castling_king = white_king.enhance
  raise "Castling king should be enhanced" unless castling_king.enhanced?
  raise "Castling king QPI should be C:+K" unless castling_king.to_s == "C:+K"

  # Diminished state (e.g., vulnerable pawn)
  pawn = Sashite::Qpi.identifier(:C, :P, :first, :normal)
  vulnerable_pawn = pawn.diminish
  raise "Vulnerable pawn should be diminished" unless vulnerable_pawn.diminished?
  raise "Vulnerable pawn QPI should be C:-P" unless vulnerable_pawn.to_s == "C:-P"
end

run_test("Japanese Chess (Shogi) pieces with QPI") do
  # Basic pieces
  sente_king = Sashite::Qpi.identifier(:S, :K, :first, :normal)
  raise "Sente king QPI should be S:K" unless sente_king.to_s == "S:K"

  gote_king = sente_king.flip
  raise "Gote king QPI should be s:k" unless gote_king.to_s == "s:k"

  # Promoted pieces
  rook = Sashite::Qpi.identifier(:S, :R, :first, :normal)
  dragon_king = rook.enhance
  raise "Dragon King should be enhanced rook" unless dragon_king.enhanced? && dragon_king.type == :R
  raise "Dragon King QPI should be S:+R" unless dragon_king.to_s == "S:+R"

  # Promoted pawn (Tokin)
  pawn = Sashite::Qpi.identifier(:S, :P, :first, :normal)
  tokin = pawn.enhance
  raise "Tokin should be enhanced pawn" unless tokin.enhanced? && tokin.type == :P
  raise "Tokin QPI should be S:+P" unless tokin.to_s == "S:+P"
end

run_test("Cross-style game scenarios with QPI") do
  # Chess vs. Ogi match
  chess_player = Sashite::Qpi.identifier(:C, :K, :first, :normal)  # First player uses Chess
  ogi_player = Sashite::Qpi.identifier(:O, :K, :second, :normal)   # Second player uses Ogi

  raise "Players should have different families" unless chess_player.cross_family?(ogi_player)
  raise "Players should have same type" unless chess_player.same_type?(ogi_player)
  raise "Players should have different sides" unless !chess_player.same_side?(ogi_player)

  # Xiongqi vs. Makruk match
  xiongqi_player = Sashite::Qpi.identifier(:X, :G, :first, :normal)  # First player uses Xiongqi
  makruk_player = Sashite::Qpi.identifier(:M, :K, :second, :normal)  # Second player uses Makruk

  raise "Cross-style match should work" unless xiongqi_player.cross_family?(makruk_player)
  raise "Xiongqi QPI should be X:G" unless xiongqi_player.to_s == "X:G"
  raise "Makruk QPI should be m:k" unless makruk_player.to_s == "m:k"
end

# Test practical usage scenarios with QPI
run_test("Practical usage - piece collections with QPI") do
  pieces = [
    Sashite::Qpi.identifier(:C, :K, :first, :normal),
    Sashite::Qpi.identifier(:C, :Q, :first, :normal),
    Sashite::Qpi.identifier(:C, :R, :first, :enhanced),
    Sashite::Qpi.identifier(:C, :K, :second, :normal),
    Sashite::Qpi.identifier(:S, :K, :first, :normal),
    Sashite::Qpi.identifier(:S, :K, :second, :normal)
  ]

  # Filter by side
  first_player_pieces = pieces.select(&:first_player?)
  raise "Should have 4 first player pieces" unless first_player_pieces.size == 4

  # Group by family
  by_family = pieces.group_by(&:family)
  raise "Should have C family grouped" unless by_family[:C].size == 4
  raise "Should have S family grouped" unless by_family[:S].size == 2

  # Find cross-family combinations
  chess_pieces = pieces.select { |p| p.family == :C }
  shogi_pieces = pieces.select { |p| p.family == :S }
  raise "Should have 4 chess pieces" unless chess_pieces.size == 4
  raise "Should have 2 shogi pieces" unless shogi_pieces.size == 2

  # Find enhanced pieces
  enhanced = pieces.select(&:enhanced?)
  raise "Should have 1 enhanced piece" unless enhanced.size == 1
  raise "Enhanced piece should be rook" unless enhanced.first.type == :R
end

run_test("Practical usage - game state simulation with QPI") do
  # Simulate cross-style match
  chess_king = Sashite::Qpi.identifier(:C, :K, :first, :normal)
  ogi_king = Sashite::Qpi.identifier(:O, :K, :second, :normal)

  raise "Should be cross-family match" unless chess_king.cross_family?(ogi_king)
  raise "Both should be kings" unless chess_king.same_type?(ogi_king)

  # Simulate promotion in different styles
  chess_pawn = Sashite::Qpi.identifier(:C, :P, :first, :normal)
  chess_queen = chess_pawn.with_type(:Q).enhance  # Promote to enhanced queen
  raise "Promoted piece should be queen" unless chess_queen.type == :Q
  raise "Promoted piece should be enhanced" unless chess_queen.enhanced?
  raise "Original pawn should be unchanged" unless chess_pawn.normal? && chess_pawn.type == :P

  ogi_pawn = Sashite::Qpi.identifier(:O, :P, :second, :normal)
  ogi_tokin = ogi_pawn.enhance  # Promote pawn in place
  raise "Ogi tokin should be enhanced pawn" unless ogi_tokin.enhanced? && ogi_tokin.type == :P
  raise "Different promotion styles" unless chess_queen.type != ogi_tokin.type
end

# Test all 26 letters for family and type
run_test("All 26 ASCII letters work correctly for family and type") do
  letters = ("A".."Z").to_a

  letters.each do |letter|
    family_symbol = letter.to_sym
    type_symbol = letter.to_sym

    # Test first player (uppercase)
    identifier = Sashite::Qpi.identifier(family_symbol, type_symbol, :first, :normal)
    expected_qpi = "#{letter}:#{letter}"
    raise "#{letter} first player should create #{expected_qpi}" unless identifier.to_s == expected_qpi

    # Test second player (lowercase)
    identifier = Sashite::Qpi.identifier(family_symbol, type_symbol, :second, :normal)
    expected_qpi = "#{letter.downcase}:#{letter.downcase}"
    raise "#{letter} second player should create #{expected_qpi}" unless identifier.to_s == expected_qpi

    # Test state modifiers
    enhanced = Sashite::Qpi.identifier(family_symbol, type_symbol, :first, :enhanced)
    expected_enhanced = "#{letter}:+#{letter}"
    raise "#{letter} enhanced should create #{expected_enhanced}" unless enhanced.to_s == expected_enhanced

    diminished = Sashite::Qpi.identifier(family_symbol, type_symbol, :second, :diminished)
    expected_diminished = "#{letter.downcase}:-#{letter.downcase}"
    raise "#{letter} diminished should create #{expected_diminished}" unless diminished.to_s == expected_diminished
  end
end

run_test("Component consistency verification") do
  test_cases = [
    "C:K", "c:k", "S:+R", "s:+r", "X:-S", "x:-s"
  ]

  test_cases.each do |qpi_string|
    identifier = Sashite::Qpi.parse(qpi_string)

    # Verify that sin and pin components have consistent sides
    sin_component = identifier.sin_component
    pin_component = identifier.pin_component

    raise "#{qpi_string}: SIN and PIN components should have same side" unless sin_component.side == pin_component.side
    raise "#{qpi_string}: identifier side should match components" unless identifier.side == sin_component.side
    raise "#{qpi_string}: identifier side should match components" unless identifier.side == pin_component.side

    # Verify that components can be used to reconstruct the identifier
    reconstructed = "#{sin_component.to_s}:#{pin_component.to_s}"
    raise "#{qpi_string}: should be reconstructible from components" unless reconstructed == qpi_string
  end
end

# Test regex compliance
run_test("Regex pattern compliance with spec") do
  # Test against the specification regex: \A([A-Z]:[-+]?[A-Z]|[a-z]:[-+]?[a-z])\z
  spec_regex = /\A([A-Z]:[-+]?[A-Z]|[a-z]:[-+]?[a-z])\z/

  test_strings = [
    # Valid QPI strings
    "C:K", "c:k", "S:+R", "s:+r", "X:-S", "x:-s", "A:A", "Z:Z", "a:a", "z:z",
    # Invalid QPI strings
    "", "C", ":K", "C:", "Chess:King", "C:k", "c:K", "CC:K", "C:KK",
    "C:+k", "c:+K", "1:K", "C:1", "++:K", "C:++K"
  ]

  test_strings.each do |string|
    spec_match = string.match?(spec_regex)
    qpi_valid = Sashite::Qpi.valid?(string)

    # Note: regex match doesn't check semantic consistency, so some regex matches may be invalid QPI
    if spec_match && !qpi_valid
      # This is expected for semantic mismatches like "C:k"
      sin_part, pin_part = string.split(":", 2) if string.include?(":")
      if sin_part && pin_part
        sin_case = sin_part == sin_part.upcase
        pin_case = pin_part.gsub(/[-+]/, "") == pin_part.gsub(/[-+]/, "").upcase
        next if sin_case != pin_case  # Semantic mismatch is expected
      end
    end

    # For non-semantic mismatches, regex and QPI validation should agree
    unless (spec_match && !qpi_valid && string.match?(/[A-Z]:[a-z]|[a-z]:[A-Z]|[A-Z]:[-+][a-z]|[a-z]:[-+][A-Z]/))
      raise "#{string.inspect}: spec regex and QPI validation disagree (regex: #{spec_match}, qpi: #{qpi_valid})" unless spec_match == qpi_valid
    end
  end
end

# Test performance with QPI
run_test("Performance - repeated operations with QPI") do
  # Test performance with many repeated calls
  1000.times do
    identifier = Sashite::Qpi.identifier(:C, :K, :first, :normal)
    enhanced = identifier.enhance
    flipped = identifier.flip
    different_family = identifier.with_family(:S)

    raise "Performance test failed" unless Sashite::Qpi.valid?("C:K")
    raise "Performance test failed" unless enhanced.enhanced?
    raise "Performance test failed" unless flipped.second_player?
    raise "Performance test failed" unless different_family.family == :S
  end
end

# Test constants and validation
run_test("Identifier class constants are properly defined") do
  identifier_class = Sashite::Qpi::Identifier

  # Test separator constant
  raise "SEPARATOR should be ':'" unless identifier_class::SEPARATOR == ":"
end

# Test roundtrip parsing
run_test("Roundtrip parsing consistency") do
  test_cases = [
    [:C, :K, :first, :normal],
    [:C, :K, :second, :normal],
    [:S, :R, :first, :enhanced],
    [:X, :S, :second, :diminished]
  ]

  test_cases.each do |family, type, side, state|
    # Create identifier -> to_s -> parse -> compare
    original = Sashite::Qpi::Identifier.new(family, type, side, state)
    qpi_string = original.to_s
    parsed = Sashite::Qpi.parse(qpi_string)

    raise "Roundtrip failed: original != parsed" unless original == parsed
    raise "Roundtrip failed: different family" unless original.family == parsed.family
    raise "Roundtrip failed: different type" unless original.type == parsed.type
    raise "Roundtrip failed: different side" unless original.side == parsed.side
    raise "Roundtrip failed: different state" unless original.state == parsed.state
  end
end

# Test case sensitivity requirements
run_test("Case sensitivity maintained correctly for QPI") do
  # Test that we properly handle case for both components
  valid_cases = ["C:K", "c:k", "S:+R", "s:+r", "X:-S", "x:-s"]
  invalid_semantic_cases = ["C:k", "c:K", "S:+r", "s:+R", "X:-s", "x:-S"]

  valid_cases.each do |qpi|
    raise "#{qpi} should be valid" unless Sashite::Qpi.valid?(qpi)
  end

  invalid_semantic_cases.each do |qpi|
    raise "#{qpi} should be invalid (semantic mismatch)" if Sashite::Qpi.valid?(qpi)
  end
end

# Test that QPI string representation is always consistent with components
run_test("String representation consistency") do
  test_cases = [
    [:C, :K, :first, :normal, "C:K"],
    [:C, :K, :second, :normal, "c:k"],
    [:S, :R, :first, :enhanced, "S:+R"],
    [:X, :S, :second, :diminished, "x:-s"]
  ]

  test_cases.each do |family, type, side, state, expected_qpi|
    identifier = Sashite::Qpi::Identifier.new(family, type, side, state)

    raise "QPI should match expected" unless identifier.to_s == expected_qpi
    raise "to_s should match sin:pin format" unless identifier.to_s == "#{identifier.to_sin}:#{identifier.to_pin}"

    # Verify that family case aligns with side
    expected_family_case = side == :first ? identifier.family.to_s.upcase : identifier.family.to_s.downcase
    raise "Family case should align with side" unless identifier.to_sin == expected_family_case
  end
end

puts
puts "All QPI v1.0.0 tests passed!"
puts
