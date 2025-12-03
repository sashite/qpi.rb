# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Qpi (Qualified Piece Identifier)
#
# Comprehensive test suite for the minimal API design covering:
# - Module-level validation and parsing
# - Pure composition of SIN and PIN primitives
# - Component access and replacement
# - Semantic consistency validation
# - Immutability and transformations
# - Equality and hashing

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
puts "Tests for Sashite::Qpi (Qualified Piece Identifier) - Minimal API"
puts

# ==============================================================================
# MODULE-LEVEL VALIDATION TESTS
# ==============================================================================

run_test("Module QPI validation accepts valid notations") do
  valid_qpis = [
    # Basic pieces
    "C:K", "C:Q", "C:R", "C:B", "C:N", "C:P",
    "c:k", "c:q", "c:r", "c:b", "c:n", "c:p",
    # Enhanced pieces
    "S:+R", "S:+B", "S:+S", "S:+N", "S:+L", "S:+P",
    "s:+r", "s:+b", "s:+s", "s:+n", "s:+l", "s:+p",
    # Diminished pieces
    "X:-S", "X:-H", "X:-E",
    "x:-s", "x:-h", "x:-e",
    # Terminal pieces
    "C:K^", "c:k^", "X:G^", "x:g^",
    # Enhanced terminal pieces
    "S:+R^", "s:+r^",
    # Diminished terminal pieces
    "X:-S^", "x:-s^",
    # All 26 letters
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
    "C:k^", "c:K^", "S:+p^", "s:+P^",
    # Invalid SIN components
    "1:K", "Chess:K", "CC:K", "++:K", "--:K", " C:K", "C :K",
    # Invalid PIN components
    "C:1", "C:King", "C:KK", "C:++K", "C:--K", "C:K+", "C:K-", "C: K", "C:K ",
    # Invalid characters
    "α:K", "C:β", "♕:K", "C:♔",
    # Whitespace issues
    " C:K", "C:K ", " C:K ", "C: K", "C :K"
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

# ==============================================================================
# MODULE-LEVEL PARSING AND CREATION TESTS
# ==============================================================================

run_test("Module parse delegates to Identifier class") do
  qpi_string = "C:K^"
  qpi = Sashite::Qpi.parse(qpi_string)

  raise "parse should return Identifier instance" unless qpi.is_a?(Sashite::Qpi::Identifier)
  raise "qpi should have correct QPI string" unless qpi.to_s == qpi_string
end

run_test("Module new creates from SIN and PIN components") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K^")
  qpi = Sashite::Qpi.new(sin, pin)

  raise "new should return Identifier instance" unless qpi.is_a?(Sashite::Qpi::Identifier)
  raise "qpi should have correct SIN component" unless qpi.sin == sin
  raise "qpi should have correct PIN component" unless qpi.pin == pin
  raise "qpi should have correct QPI string" unless qpi.to_s == "C:K^"
end

# ==============================================================================
# IDENTIFIER CREATION AND PARSING TESTS
# ==============================================================================

run_test("Identifier.parse creates correct instances") do
  test_cases = {
    "C:K" => { sin_str: "C", pin_str: "K" },
    "c:k" => { sin_str: "c", pin_str: "k" },
    "S:+R" => { sin_str: "S", pin_str: "+R" },
    "s:+r" => { sin_str: "s", pin_str: "+r" },
    "X:-S" => { sin_str: "X", pin_str: "-S" },
    "x:-s" => { sin_str: "x", pin_str: "-s" },
    "C:K^" => { sin_str: "C", pin_str: "K^" },
    "S:+R^" => { sin_str: "S", pin_str: "+R^" },
    "x:-s^" => { sin_str: "x", pin_str: "-s^" }
  }

  test_cases.each do |qpi_string, expected|
    qpi = Sashite::Qpi.parse(qpi_string)

    raise "#{qpi_string}: wrong SIN component" unless qpi.sin.to_s == expected[:sin_str]
    raise "#{qpi_string}: wrong PIN component" unless qpi.pin.to_s == expected[:pin_str]
    raise "#{qpi_string}: wrong QPI string" unless qpi.to_s == qpi_string
  end
end

run_test("Identifier constructor with SIN and PIN components") do
  test_cases = [
    ["C", "K^", "C:K^"],
    ["c", "k^", "c:k^"],
    ["S", "+R", "S:+R"],
    ["s", "+r", "s:+r"],
    ["X", "-S", "X:-S"],
    ["x", "-s^", "x:-s^"]
  ]

  test_cases.each do |sin_str, pin_str, expected_qpi|
    sin = Sashite::Sin.parse(sin_str)
    pin = Sashite::Pin.parse(pin_str)
    qpi = Sashite::Qpi::Identifier.new(sin, pin)

    raise "QPI string should be #{expected_qpi}" unless qpi.to_s == expected_qpi
    raise "SIN component should match" unless qpi.sin == sin
    raise "PIN component should match" unless qpi.pin == pin
  end
end

# ==============================================================================
# COMPONENT ACCESS TESTS
# ==============================================================================

run_test("Identifier component access methods") do
  test_cases = [
    ["C:K^", "C", "K^"],
    ["c:k^", "c", "k^"],
    ["S:+R", "S", "+R"],
    ["x:-s^", "x", "-s^"]
  ]

  test_cases.each do |qpi_string, expected_sin, expected_pin|
    qpi = Sashite::Qpi.parse(qpi_string)

    raise "#{qpi_string}: wrong SIN component" unless qpi.sin.to_s == expected_sin
    raise "#{qpi_string}: wrong PIN component" unless qpi.pin.to_s == expected_pin
    raise "#{qpi_string}: sin should be SIN::Identifier" unless qpi.sin.is_a?(Sashite::Sin::Identifier)
    raise "#{qpi_string}: pin should be PIN::Identifier" unless qpi.pin.is_a?(Sashite::Pin::Identifier)
  end
end

run_test("Identifier attributes via components") do
  qpi = Sashite::Qpi.parse("S:+R^")

  # Access five fundamental attributes via components
  raise "wrong family" unless qpi.sin.family == :S
  raise "wrong type" unless qpi.pin.type == :R
  raise "wrong side" unless qpi.sin.side == :first
  raise "wrong state" unless qpi.pin.state == :enhanced
  raise "wrong terminal" unless qpi.pin.terminal? == true

  # Verify side consistency
  raise "SIN and PIN sides should match" unless qpi.sin.side == qpi.pin.side
end

# ==============================================================================
# STRING REPRESENTATION TESTS
# ==============================================================================

run_test("Identifier to_s returns correct QPI string") do
  test_cases = [
    [["C", "K^"], "C:K^"],
    [["c", "k^"], "c:k^"],
    [["S", "+R"], "S:+R"],
    [["x", "-s^"], "x:-s^"]
  ]

  test_cases.each do |components, expected|
    sin = Sashite::Sin.parse(components[0])
    pin = Sashite::Pin.parse(components[1])
    qpi = Sashite::Qpi::Identifier.new(sin, pin)

    raise "QPI string should be #{expected}, got #{qpi.to_s}" unless qpi.to_s == expected
  end
end

# ==============================================================================
# COMPONENT REPLACEMENT TESTS
# ==============================================================================

run_test("Identifier with_sin replaces SIN component") do
  qpi = Sashite::Qpi.parse("C:K^")
  new_sin = Sashite::Sin.parse("S")
  new_qpi = qpi.with_sin(new_sin)

  raise "with_sin should return new instance" if new_qpi.equal?(qpi)
  raise "new QPI should have different SIN" unless new_qpi.sin == new_sin
  raise "new QPI should have same PIN" unless new_qpi.pin == qpi.pin
  raise "new QPI string should be S:K^" unless new_qpi.to_s == "S:K^"
  raise "original QPI should be unchanged" unless qpi.to_s == "C:K^"
end

run_test("Identifier with_sin returns self when same") do
  qpi = Sashite::Qpi.parse("C:K^")
  result = qpi.with_sin(qpi.sin)

  raise "with_sin with same SIN should return self" unless result.equal?(qpi)
end

run_test("Identifier with_pin replaces PIN component") do
  qpi = Sashite::Qpi.parse("C:K^")
  new_pin = Sashite::Pin.parse("Q^")
  new_qpi = qpi.with_pin(new_pin)

  raise "with_pin should return new instance" if new_qpi.equal?(qpi)
  raise "new QPI should have same SIN" unless new_qpi.sin == qpi.sin
  raise "new QPI should have different PIN" unless new_qpi.pin == new_pin
  raise "new QPI string should be C:Q^" unless new_qpi.to_s == "C:Q^"
  raise "original QPI should be unchanged" unless qpi.to_s == "C:K^"
end

run_test("Identifier with_pin returns self when same") do
  qpi = Sashite::Qpi.parse("C:K^")
  result = qpi.with_pin(qpi.pin)

  raise "with_pin with same PIN should return self" unless result.equal?(qpi)
end

# ==============================================================================
# FLIP METHOD TESTS
# ==============================================================================

run_test("Identifier flip flips both components") do
  qpi = Sashite::Qpi.parse("C:K^")
  flipped = qpi.flip

  raise "flip should return new instance" if flipped.equal?(qpi)
  raise "flipped QPI should have opposite side" unless flipped.sin.side == :second
  raise "flipped QPI should have opposite side" unless flipped.pin.side == :second
  raise "flipped QPI string should be c:k^" unless flipped.to_s == "c:k^"
  raise "original QPI should be unchanged" unless qpi.to_s == "C:K^"
end

run_test("Identifier flip preserves all attributes except side") do
  qpi = Sashite::Qpi.parse("S:+R^")
  flipped = qpi.flip

  raise "flip should preserve family" unless flipped.sin.family == qpi.sin.family
  raise "flip should preserve type" unless flipped.pin.type == qpi.pin.type
  raise "flip should preserve state" unless flipped.pin.state == qpi.pin.state
  raise "flip should preserve terminal" unless flipped.pin.terminal? == qpi.pin.terminal?
  raise "flip should change side" unless flipped.sin.side != qpi.sin.side
  raise "flipped QPI string should be s:+r^" unless flipped.to_s == "s:+r^"
end

# ==============================================================================
# TRANSFORMATION CHAINS TESTS
# ==============================================================================

run_test("Identifier transformation chains work correctly") do
  qpi = Sashite::Qpi.parse("C:K^")

  # Chain with_sin and with_pin
  transformed = qpi
    .with_sin(qpi.sin.with_family(:S))
    .with_pin(qpi.pin.with_type(:R))

  raise "chained transformation should work" unless transformed.to_s == "S:R^"
  raise "original should be unchanged" unless qpi.to_s == "C:K^"
end

run_test("Identifier flip then flip returns equivalent") do
  qpi = Sashite::Qpi.parse("C:K^")
  flipped_twice = qpi.flip.flip

  raise "flip twice should return to original side" unless flipped_twice.to_s == "C:K^"
  raise "flip twice should be equal to original" unless flipped_twice == qpi
end

run_test("Identifier complex transformation chain") do
  qpi = Sashite::Qpi.parse("C:K^")

  # Complex chain: flip, change family, change type, flip again
  transformed = qpi
    .flip
    .with_sin(qpi.sin.flip.with_family(:S))
    .with_pin(qpi.pin.flip.with_type(:Q).with_state(:enhanced))
    .flip

  raise "complex chain should work" unless transformed.to_s == "S:+Q^"
  raise "original should be unchanged" unless qpi.to_s == "C:K^"
end

# ==============================================================================
# SEMANTIC CONSISTENCY VALIDATION TESTS
# ==============================================================================

run_test("Identifier rejects side mismatch in constructor") do
  sin_first = Sashite::Sin.parse("C")   # first player
  pin_second = Sashite::Pin.parse("k")  # second player

  begin
    Sashite::Qpi::Identifier.new(sin_first, pin_second)
    raise "Should have raised error for side mismatch"
  rescue ArgumentError => e
    raise "Error message should mention side mismatch" unless e.message.include?("same side")
  end
end

run_test("Identifier rejects side mismatch in parsing") do
  mismatched_cases = [
    "C:k",   # first player SIN, second player PIN
    "c:K",   # second player SIN, first player PIN
    "S:+p",  # first player SIN, second player enhanced PIN
    "s:+P",  # second player SIN, first player enhanced PIN
    "X:-r^", # first player SIN, second player diminished terminal PIN
    "x:-R^"  # second player SIN, first player diminished terminal PIN
  ]

  mismatched_cases.each do |qpi_string|
    raise "#{qpi_string} should be invalid" if Sashite::Qpi.valid?(qpi_string)

    begin
      Sashite::Qpi.parse(qpi_string)
      raise "Should have raised error for #{qpi_string}"
    rescue ArgumentError
      # Expected
    end
  end
end

run_test("Identifier rejects side mismatch in with_sin") do
  qpi = Sashite::Qpi.parse("C:K^")
  wrong_sin = Sashite::Sin.parse("s")  # second player

  begin
    qpi.with_sin(wrong_sin)
    raise "Should have raised error for side mismatch"
  rescue ArgumentError => e
    raise "Error message should mention side mismatch" unless e.message.include?("same side")
  end
end

run_test("Identifier rejects side mismatch in with_pin") do
  qpi = Sashite::Qpi.parse("C:K^")
  wrong_pin = Sashite::Pin.parse("k")  # second player

  begin
    qpi.with_pin(wrong_pin)
    raise "Should have raised error for side mismatch"
  rescue ArgumentError => e
    raise "Error message should mention side mismatch" unless e.message.include?("same side")
  end
end

# ==============================================================================
# IMMUTABILITY TESTS
# ==============================================================================

run_test("Identifier immutability") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K^")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)

  raise "qpi should be frozen" unless qpi.frozen?
  raise "sin component should be frozen" unless qpi.sin.frozen?
  raise "pin component should be frozen" unless qpi.pin.frozen?
end

run_test("Identifier transformations don't affect original") do
  original = Sashite::Qpi.parse("C:K^")
  original_string = original.to_s

  # Apply various transformations
  original.flip
  original.with_sin(Sashite::Sin.parse("S"))
  original.with_pin(Sashite::Pin.parse("Q^"))

  raise "original should be unchanged" unless original.to_s == original_string
end

# ==============================================================================
# EQUALITY AND HASH TESTS
# ==============================================================================

run_test("Identifier equality and hash") do
  sin1 = Sashite::Sin.parse("C")
  pin1 = Sashite::Pin.parse("K^")
  qpi1 = Sashite::Qpi::Identifier.new(sin1, pin1)

  sin2 = Sashite::Sin.parse("C")
  pin2 = Sashite::Pin.parse("K^")
  qpi2 = Sashite::Qpi::Identifier.new(sin2, pin2)

  sin3 = Sashite::Sin.parse("c")
  pin3 = Sashite::Pin.parse("k^")
  qpi3 = Sashite::Qpi::Identifier.new(sin3, pin3)

  sin4 = Sashite::Sin.parse("S")
  pin4 = Sashite::Pin.parse("K^")
  qpi4 = Sashite::Qpi::Identifier.new(sin4, pin4)

  # Test equality
  raise "identical QPIs should be equal" unless qpi1 == qpi2
  raise "different side should not be equal" if qpi1 == qpi3
  raise "different family should not be equal" if qpi1 == qpi4

  # Test hash consistency
  raise "equal QPIs should have same hash" unless qpi1.hash == qpi2.hash

  # Test in Set
  qpis_set = Set.new([qpi1, qpi2, qpi3, qpi4])
  raise "set should contain 3 unique QPIs" unless qpis_set.size == 3
end

# ==============================================================================
# ERROR HANDLING TESTS
# ==============================================================================

run_test("Identifier error handling for invalid QPI strings") do
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

# ==============================================================================
# COMPONENT COMPARISON TESTS
# ==============================================================================

run_test("Identifier comparison via components") do
  qpi1 = Sashite::Qpi.parse("C:K^")
  qpi2 = Sashite::Qpi.parse("c:k^")
  qpi3 = Sashite::Qpi.parse("S:K^")
  qpi4 = Sashite::Qpi.parse("C:Q^")

  # Compare families via SIN components
  raise "C and c should have same family" unless qpi1.sin.same_family?(qpi2.sin)
  raise "C and S should have different families" if qpi1.sin.same_family?(qpi3.sin)

  # Compare types via PIN components
  raise "K and K should have same type" unless qpi1.pin.same_type?(qpi2.pin)
  raise "K and Q should have different types" if qpi1.pin.same_type?(qpi4.pin)

  # Compare sides
  raise "C and S should have same side" unless qpi1.sin.same_side?(qpi3.sin)
  raise "C and c should have different sides" if qpi1.sin.same_side?(qpi2.sin)
end

# ==============================================================================
# PRACTICAL USAGE SCENARIOS
# ==============================================================================

run_test("Practical usage - piece collections") do
  pieces = [
    Sashite::Qpi.parse("C:K^"),
    Sashite::Qpi.parse("C:Q"),
    Sashite::Qpi.parse("C:R"),
    Sashite::Qpi.parse("c:k^"),
    Sashite::Qpi.parse("S:K^"),
    Sashite::Qpi.parse("s:+r")
  ]

  # Filter by side via SIN component
  first_player = pieces.select { |p| p.sin.first_player? }
  raise "Should have 4 first player pieces" unless first_player.size == 4

  # Group by family via SIN component
  by_family = pieces.group_by { |p| p.sin.family }
  raise "Should have C family grouped" unless by_family[:C].size == 4

  # Find enhanced pieces via PIN component
  enhanced = pieces.select { |p| p.pin.enhanced? }
  raise "Should have 1 enhanced piece" unless enhanced.size == 1

  # Find terminal pieces via PIN component
  terminal = pieces.select { |p| p.pin.terminal? }
  raise "Should have 3 terminal pieces" unless terminal.size == 3
end

run_test("Practical usage - transformation via components") do
  # Start with Chess king
  qpi = Sashite::Qpi.parse("C:K^")

  # Change to Shogi style (via SIN)
  shogi_king = qpi.with_sin(qpi.sin.with_family(:S))
  raise "Should be S:K^" unless shogi_king.to_s == "S:K^"

  # Change to queen (via PIN)
  chess_queen = qpi.with_pin(qpi.pin.with_type(:Q))
  raise "Should be C:Q^" unless chess_queen.to_s == "C:Q^"

  # Enhance piece (via PIN)
  enhanced = qpi.with_pin(qpi.pin.with_state(:enhanced))
  raise "Should be C:+K^" unless enhanced.to_s == "C:+K^"

  # Remove terminal marker (via PIN)
  non_terminal = qpi.with_pin(qpi.pin.with_terminal(false))
  raise "Should be C:K" unless non_terminal.to_s == "C:K"

  # Switch player (flip)
  opponent = qpi.flip
  raise "Should be c:k^" unless opponent.to_s == "c:k^"
end

# ==============================================================================
# ROUNDTRIP PARSING TESTS
# ==============================================================================

run_test("Roundtrip parsing consistency") do
  test_cases = [
    "C:K^", "c:k^", "S:+R", "s:+r", "X:-S^", "x:-s^"
  ]

  test_cases.each do |qpi_string|
    # Parse -> to_s -> parse -> compare
    original = Sashite::Qpi.parse(qpi_string)
    string = original.to_s
    parsed = Sashite::Qpi.parse(string)

    raise "Roundtrip failed for #{qpi_string}" unless original == parsed
    raise "Roundtrip failed: string mismatch" unless string == qpi_string
  end
end

# ==============================================================================
# ALL 26 LETTERS TESTS
# ==============================================================================

run_test("All 26 ASCII letters work correctly") do
  letters = ("A".."Z").to_a

  letters.each do |letter|
    # Test first player
    qpi_first = Sashite::Qpi.parse("#{letter}:#{letter}")
    raise "#{letter} should create valid QPI" unless qpi_first.sin.family == letter.to_sym
    raise "#{letter} should be first player" unless qpi_first.sin.first_player?

    # Test second player
    qpi_second = Sashite::Qpi.parse("#{letter.downcase}:#{letter.downcase}")
    raise "#{letter} should create valid QPI" unless qpi_second.sin.family == letter.to_sym
    raise "#{letter} should be second player" unless qpi_second.sin.second_player?

    # Test with terminal marker
    qpi_terminal = Sashite::Qpi.parse("#{letter}:#{letter}^")
    raise "#{letter} terminal should work" unless qpi_terminal.pin.terminal?

    # Test with state modifiers
    qpi_enhanced = Sashite::Qpi.parse("#{letter}:+#{letter}")
    raise "#{letter} enhanced should work" unless qpi_enhanced.pin.enhanced?

    qpi_diminished = Sashite::Qpi.parse("#{letter.downcase}:-#{letter.downcase}")
    raise "#{letter} diminished should work" unless qpi_diminished.pin.diminished?
  end
end

# ==============================================================================
# REGEX COMPLIANCE TESTS
# ==============================================================================

run_test("Regex pattern compliance with spec") do
  # Test against specification regex: \A([A-Z]:[-+]?[A-Z]\^?|[a-z]:[-+]?[a-z]\^?)\z
  spec_regex = /\A([A-Z]:[-+]?[A-Z]\^?|[a-z]:[-+]?[a-z]\^?)\z/

  test_strings = [
    # Valid
    "C:K", "c:k", "S:+R", "s:+r", "X:-S", "x:-s",
    "C:K^", "c:k^", "S:+R^", "s:+r^", "X:-S^", "x:-s^",
    # Invalid
    "", "C", ":K", "C:", "Chess:King", "C:k", "c:K",
    "C:+k", "c:+K", "1:K", "C:1"
  ]

  test_strings.each do |string|
    spec_match = string.match?(spec_regex)
    qpi_valid = Sashite::Qpi.valid?(string)

    # For semantic mismatches, regex matches but QPI rejects
    if spec_match && !qpi_valid && string.match?(/[A-Z]:[+-]?[a-z]|[a-z]:[+-]?[A-Z]/)
      next  # Expected semantic mismatch
    end

    raise "#{string.inspect}: spec regex and QPI validation disagree" unless spec_match == qpi_valid
  end
end

puts
puts "All QPI v1.0.0 tests passed!"
puts
