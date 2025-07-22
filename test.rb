# frozen_string_literal: true

# Tests for Sashite::Qpi (Qualified Piece Identifier)
#
# Tests the QPI implementation for Ruby, focusing on the modern object-oriented API
# with the Identifier class combining SIN and PIN components with semantic validation.

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
puts "Tests for Sashite::Qpi (Qualified Piece Identifier)"
puts

# Test basic validation (module level)
run_test("Module QPI validation accepts valid notations") do
  valid_qpis = [
    "C:K", "C:Q", "C:R", "C:B", "C:N", "C:P",
    "c:k", "c:q", "c:r", "c:b", "c:n", "c:p",
    "S:K", "S:G", "S:S", "S:N", "S:L", "S:P",
    "s:k", "s:g", "s:s", "s:n", "s:l", "s:p",
    "C:+K", "C:+Q", "C:+R", "c:+k", "c:+q", "c:+r",
    "S:-K", "S:-P", "s:-k", "s:-p",
    "A:A", "Z:Z", "a:a", "z:z"
  ]

  valid_qpis.each do |qpi|
    raise "#{qpi.inspect} should be valid" unless Sashite::Qpi.valid?(qpi)
  end
end

run_test("Module QPI validation rejects invalid notations") do
  invalid_qpis = [
    # Missing separator
    "", "C", "K", "CK", "Chess", "CHESS",

    # Wrong separator
    "C-K", "C K", "C.K", "C;K", "C|K",

    # Multiple separators
    "C:K:", ":C:K", "C::K", "C:K:R",

    # Invalid SIN components
    "CC:K", "1:K", "Chess:K", "CHESS:K", "!:K",

    # Invalid PIN components
    "C:KK", "C:1", "C:Chess", "C:++K", "C:--K", "C:+-K", "C:-+K",

    # Semantic mismatches (different sides)
    "C:k", "C:q", "C:+r", "C:-p",
    "c:K", "c:Q", "c:+R", "c:-P",
    "S:k", "S:+p", "s:K", "s:+P",

    # Edge cases
    ":", "C:", ":K", " C:K", "C:K ", " C:K ", "\tC:K", "C:K\t"
  ]

  invalid_qpis.each do |qpi|
    raise "#{qpi.inspect} should be invalid" if Sashite::Qpi.valid?(qpi)
  end
end

run_test("Module QPI validation handles non-string input") do
  non_strings = [nil, 123, :chess, [], {}, true, false, 1.5, Object.new]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Qpi.valid?(input)
  end
end

# Test module parse method delegates to Identifier
run_test("Module parse delegates to Identifier class") do
  qpi_string = "C:+R"
  identifier = Sashite::Qpi.parse(qpi_string)

  raise "parse should return Identifier instance" unless identifier.is_a?(Sashite::Qpi::Identifier)
  raise "identifier should have correct QPI string" unless identifier.to_s == qpi_string
end

# Test module identifier factory method
run_test("Module identifier factory method creates correct instances") do
  identifier = Sashite::Qpi.identifier("C", "K")

  raise "identifier factory should return Identifier instance" unless identifier.is_a?(Sashite::Qpi::Identifier)
  raise "identifier should have correct SIN" unless identifier.sin == :C
  raise "identifier should have correct PIN" unless identifier.pin == :K
  raise "identifier should have correct QPI string" unless identifier.to_s == "C:K"
end

# Test the Identifier class with component-based API
run_test("Identifier.parse creates correct instances with component attributes") do
  test_cases = {
    "C:K" => { sin: :C, pin: :K, style: :C, type: :K, side: :first, state: :normal },
    "c:k" => { sin: :c, pin: :k, style: :c, type: :K, side: :second, state: :normal },
    "S:+R" => { sin: :S, pin: :"+R", style: :S, type: :R, side: :first, state: :enhanced },
    "s:-p" => { sin: :s, pin: :"-p", style: :s, type: :P, side: :second, state: :diminished }
  }

  test_cases.each do |qpi_string, expected|
    identifier = Sashite::Qpi.parse(qpi_string)

    raise "#{qpi_string}: wrong sin" unless identifier.sin == expected[:sin]
    raise "#{qpi_string}: wrong pin" unless identifier.pin == expected[:pin]
    raise "#{qpi_string}: wrong style" unless identifier.style == expected[:style]
    raise "#{qpi_string}: wrong type" unless identifier.type == expected[:type]
    raise "#{qpi_string}: wrong side" unless identifier.side == expected[:side]
    raise "#{qpi_string}: wrong state" unless identifier.state == expected[:state]
  end
end

run_test("Identifier constructor with component parameters") do
  test_cases = [
    ["C", "K", "C:K"],
    ["c", "k", "c:k"],
    ["S", "+R", "S:+R"],
    ["s", "-p", "s:-p"]
  ]

  test_cases.each do |sin_str, pin_str, expected_qpi|
    identifier = Sashite::Qpi::Identifier.new(sin_str, pin_str)

    raise "sin should be #{sin_str}" unless identifier.sin.to_s == sin_str
    raise "pin should be #{pin_str}" unless identifier.pin.to_s == pin_str
    raise "QPI string should be #{expected_qpi}" unless identifier.to_s == expected_qpi
  end
end

run_test("Identifier to_s returns correct QPI string") do
  test_cases = [
    ["C", "K", "C:K"],
    ["c", "k", "c:k"],
    ["S", "+R", "S:+R"],
    ["s", "-p", "s:-p"]
  ]

  test_cases.each do |sin_str, pin_str, expected|
    identifier = Sashite::Qpi::Identifier.new(sin_str, pin_str)
    result = identifier.to_s

    raise "#{sin_str}, #{pin_str} should be #{expected}, got #{result}" unless result == expected
  end
end

run_test("Identifier component extraction methods") do
  test_cases = [
    ["C:K", "C", "K"],
    ["c:k", "c", "k"],
    ["S:+R", "S", "+R"],
    ["s:-p", "s", "-p"]
  ]

  test_cases.each do |qpi_string, expected_sin, expected_pin|
    identifier = Sashite::Qpi.parse(qpi_string)

    raise "#{qpi_string}: wrong to_sin" unless identifier.to_sin == expected_sin
    raise "#{qpi_string}: wrong to_pin" unless identifier.to_pin == expected_pin
    raise "#{qpi_string}: to_s should equal sin:pin" unless identifier.to_s == "#{identifier.to_sin}:#{identifier.to_pin}"
  end
end

run_test("Identifier component access methods") do
  identifier = Sashite::Qpi.parse("S:+K")

  # Test component objects
  sin_component = identifier.sin_component
  pin_component = identifier.pin_component

  raise "sin_component should be SIN identifier" unless sin_component.is_a?(Sashite::Sin::Identifier)
  raise "pin_component should be PIN identifier" unless pin_component.is_a?(Sashite::Pin::Identifier)
  raise "sin_component should match" unless sin_component.to_s == "S"
  raise "pin_component should match" unless pin_component.to_s == "+K"
end

run_test("Identifier state transformations return new instances") do
  identifier = Sashite::Qpi::Identifier.new("C", "K")

  # Test enhance
  enhanced = identifier.enhance
  raise "enhance should return new instance" if enhanced.equal?(identifier)
  raise "enhanced identifier should be enhanced" unless enhanced.enhanced?
  raise "enhanced identifier should have enhanced PIN" unless enhanced.to_pin == "+K"
  raise "enhanced identifier should keep same SIN" unless enhanced.to_sin == "C"
  raise "original identifier should be unchanged" unless identifier.to_s == "C:K"

  # Test diminish
  diminished = identifier.diminish
  raise "diminish should return new instance" if diminished.equal?(identifier)
  raise "diminished identifier should be diminished" unless diminished.diminished?
  raise "diminished identifier should have diminished PIN" unless diminished.to_pin == "-K"
  raise "diminished identifier should keep same SIN" unless diminished.to_sin == "C"

  # Test normalize
  normalized = enhanced.normalize
  raise "normalize should return new instance" if normalized.equal?(enhanced)
  raise "normalized identifier should be normal" unless normalized.normal?
  raise "normalized identifier should equal original" unless normalized.to_s == identifier.to_s
end

run_test("Identifier attribute transformations") do
  identifier = Sashite::Qpi::Identifier.new("C", "K")

  # Test with_type
  queen = identifier.with_type(:Q)
  raise "with_type should return new instance" if queen.equal?(identifier)
  raise "new identifier should have different type" unless queen.type == :Q
  raise "new identifier should have same style and side" unless queen.to_s == "C:Q"

  # Test with_style
  shogi_king = identifier.with_style(:S)
  raise "with_style should return new instance" if shogi_king.equal?(identifier)
  raise "new identifier should have different style" unless shogi_king.style == :S
  raise "new identifier should have same type and side" unless shogi_king.to_s == "S:K"

  # Test flip_side
  black_king = identifier.flip_side
  raise "flip_side should return new instance" if black_king.equal?(identifier)
  raise "flipped identifier should be second player" unless black_king.second_player?
  raise "flipped identifier should have both components flipped" unless black_king.to_s == "c:k"

  # Test flip_style
  black_style = identifier.flip_style
  raise "flip_style should return new instance" if black_style.equal?(identifier)
  raise "flipped style should have lowercase SIN" unless black_style.to_sin == "c"
  raise "flipped style should keep same PIN" unless black_style.to_pin == "K"

  # Test flip (should be same as flip_side)
  flipped = identifier.flip
  raise "flip should equal flip_side" unless flipped.to_s == black_king.to_s
end

run_test("Identifier with_components method") do
  identifier = Sashite::Qpi::Identifier.new("C", "K")

  new_identifier = identifier.with_components("S", "+R")
  raise "with_components should return new instance" if new_identifier.equal?(identifier)
  raise "new identifier should have new components" unless new_identifier.to_s == "S:+R"
  raise "original should be unchanged" unless identifier.to_s == "C:K"
end

run_test("Identifier immutability") do
  identifier = Sashite::Qpi::Identifier.new("S", "+R")

  # Test that identifier is frozen
  raise "identifier should be frozen" unless identifier.frozen?

  # Test that transformations don't affect original
  original_string = identifier.to_s
  enhanced = identifier.enhance
  normalized = identifier.normalize

  raise "original identifier should be unchanged" unless identifier.to_s == original_string
  raise "enhanced should be different" unless enhanced.to_s == "S:+R" # Already enhanced
  raise "normalized should be different" unless normalized.to_s == "S:R"
end

run_test("Identifier equality and hash") do
  identifier1 = Sashite::Qpi::Identifier.new("C", "K")
  identifier2 = Sashite::Qpi::Identifier.new("C", "K")
  identifier3 = Sashite::Qpi::Identifier.new("c", "k")
  identifier4 = Sashite::Qpi::Identifier.new("S", "K")

  # Test equality
  raise "identical identifiers should be equal" unless identifier1 == identifier2
  raise "different side should not be equal" if identifier1 == identifier3
  raise "different style should not be equal" if identifier1 == identifier4

  # Test hash consistency
  raise "equal identifiers should have same hash" unless identifier1.hash == identifier2.hash

  # Test in hash/set
  identifiers_set = Set.new([identifier1, identifier2, identifier3, identifier4])
  raise "set should contain 3 unique identifiers" unless identifiers_set.size == 3
end

run_test("Identifier attribute access") do
  test_cases = [
    ["C:K", :C, :K, :C, :K, :first, :normal],
    ["c:k", :c, :k, :c, :K, :second, :normal],
    ["S:+R", :S, :"+R", :S, :R, :first, :enhanced],
    ["s:-p", :s, :"-p", :s, :P, :second, :diminished]
  ]

  test_cases.each do |qpi_string, expected_sin, expected_pin, expected_style, expected_type, expected_side, expected_state|
    identifier = Sashite::Qpi.parse(qpi_string)

    raise "#{qpi_string}: wrong sin" unless identifier.sin == expected_sin
    raise "#{qpi_string}: wrong pin" unless identifier.pin == expected_pin
    raise "#{qpi_string}: wrong style" unless identifier.style == expected_style
    raise "#{qpi_string}: wrong type" unless identifier.type == expected_type
    raise "#{qpi_string}: wrong side" unless identifier.side == expected_side
    raise "#{qpi_string}: wrong state" unless identifier.state == expected_state
  end
end

run_test("Identifier comparison methods") do
  chess_white_king = Sashite::Qpi::Identifier.new("C", "K")
  chess_black_king = Sashite::Qpi::Identifier.new("c", "k")
  chess_white_queen = Sashite::Qpi::Identifier.new("C", "Q")
  shogi_white_king = Sashite::Qpi::Identifier.new("S", "K")
  enhanced_chess_king = Sashite::Qpi::Identifier.new("C", "+K")

  # same_style? tests
  raise "C and c should be same style" unless chess_white_king.same_style?(chess_black_king)
  raise "C and S should not be same style" if chess_white_king.same_style?(shogi_white_king)

  # cross_style? tests
  raise "C and S should be cross style" unless chess_white_king.cross_style?(shogi_white_king)
  raise "C and c should not be cross style" if chess_white_king.cross_style?(chess_black_king)

  # same_side? tests
  raise "first player identifiers should be same side" unless chess_white_king.same_side?(chess_white_queen)
  raise "first player identifiers should be same side" unless chess_white_king.same_side?(shogi_white_king)
  raise "different side identifiers should not be same side" if chess_white_king.same_side?(chess_black_king)

  # same_type? tests
  raise "K and K should be same type" unless chess_white_king.same_type?(chess_black_king)
  raise "K and K should be same type" unless chess_white_king.same_type?(shogi_white_king)
  raise "K and Q should not be same type" if chess_white_king.same_type?(chess_white_queen)

  # same_state? tests
  raise "normal identifiers should be same state" unless chess_white_king.same_state?(chess_black_king)
  raise "different state identifiers should not be same state" if chess_white_king.same_state?(enhanced_chess_king)
end

run_test("Identifier state methods") do
  normal = Sashite::Qpi::Identifier.new("C", "K")
  enhanced = Sashite::Qpi::Identifier.new("C", "+K")
  diminished = Sashite::Qpi::Identifier.new("C", "-K")

  # Test state identification
  raise "normal identifier should be normal" unless normal.normal?
  raise "normal identifier should not be enhanced" if normal.enhanced?
  raise "normal identifier should not be diminished" if normal.diminished?

  raise "enhanced identifier should be enhanced" unless enhanced.enhanced?
  raise "enhanced identifier should not be normal" if enhanced.normal?
  raise "enhanced identifier should not be diminished" if enhanced.diminished?

  raise "diminished identifier should be diminished" unless diminished.diminished?
  raise "diminished identifier should not be normal" if diminished.normal?
  raise "diminished identifier should not be enhanced" if diminished.enhanced?
end

run_test("Identifier side methods") do
  first_player = Sashite::Qpi::Identifier.new("C", "K")
  second_player = Sashite::Qpi::Identifier.new("c", "k")

  raise "first player identifier should be first player" unless first_player.first_player?
  raise "first player identifier should not be second player" if first_player.second_player?

  raise "second player identifier should be second player" unless second_player.second_player?
  raise "second player identifier should not be first player" if second_player.first_player?
end

run_test("Identifier transformation methods return self when appropriate") do
  normal_identifier = Sashite::Qpi::Identifier.new("C", "K")
  enhanced_identifier = Sashite::Qpi::Identifier.new("C", "+K")
  diminished_identifier = Sashite::Qpi::Identifier.new("C", "-K")

  # Test methods that should return self
  raise "with_type with same type should return self" unless normal_identifier.with_type(:K).equal?(normal_identifier)
  raise "with_style with same style should return self" unless normal_identifier.with_style(:C).equal?(normal_identifier)
  raise "enhance on enhanced identifier should return self" unless enhanced_identifier.enhance.equal?(enhanced_identifier)
  raise "diminish on diminished identifier should return self" unless diminished_identifier.diminish.equal?(diminished_identifier)
  raise "normalize on normal identifier should return self" unless normal_identifier.normalize.equal?(normal_identifier)
end

run_test("Identifier transformation chains") do
  identifier = Sashite::Qpi::Identifier.new("C", "K")

  # Test enhance then normalize
  enhanced = identifier.enhance
  back_to_normal = enhanced.normalize
  raise "enhance then normalize should equal original" unless back_to_normal == identifier

  # Test complex chain
  transformed = identifier.flip_side.with_style(:S).enhance.with_type(:Q)
  raise "complex chain should work" unless transformed.to_s == "s:+q"
  raise "original should be unchanged" unless identifier.to_s == "C:K"
end

run_test("Identifier error handling for invalid components") do
  # Invalid SIN components
  invalid_sins = ["", "CC", "Chess", "1", "!"]

  invalid_sins.each do |sin|
    begin
      Sashite::Qpi::Identifier.new(sin, "K")
      raise "Should have raised error for invalid SIN #{sin.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid SIN" unless e.message.include?("Invalid SIN")
    end
  end

  # Invalid PIN components
  invalid_pins = ["", "KK", "++K", "Chess", "1"]

  invalid_pins.each do |pin|
    begin
      Sashite::Qpi::Identifier.new("C", pin)
      raise "Should have raised error for invalid PIN #{pin.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid PIN" unless e.message.include?("Invalid PIN")
    end
  end
end

run_test("Identifier error handling for semantic mismatches") do
  # SIN and PIN with different sides
  semantic_mismatches = [
    ["C", "k"], # First player style, second player piece
    ["c", "K"], # Second player style, first player piece
    ["S", "+r"], # First player style, second player piece
    ["s", "+R"]  # Second player style, first player piece
  ]

  semantic_mismatches.each do |sin_str, pin_str|
    begin
      Sashite::Qpi::Identifier.new(sin_str, pin_str)
      raise "Should have raised error for semantic mismatch #{sin_str}:#{pin_str}"
    rescue ArgumentError => e
      raise "Error message should mention semantic mismatch" unless e.message.include?("must represent the same player side")
    end
  end
end

run_test("Identifier error handling for invalid QPI strings") do
  # Invalid QPI strings
  invalid_qpis = ["", "C", "K", "Chess", "C:k", "c:K", "CC:K", "C:KK", nil]

  invalid_qpis.each do |qpi|
    begin
      Sashite::Qpi.parse(qpi) if qpi
      raise "Should have raised error for #{qpi.inspect}" unless qpi.nil?
    rescue ArgumentError
      # Expected for invalid inputs
    rescue TypeError
      # Expected for nil input
    end
  end
end

# Test semantic validation with module methods
run_test("Module methods validate semantic consistency") do
  # Valid semantic combinations
  valid_combinations = ["C:K", "c:k", "S:+R", "s:-p"]
  valid_combinations.each do |qpi|
    raise "#{qpi} should be valid" unless Sashite::Qpi.valid?(qpi)
  end

  # Invalid semantic combinations
  invalid_combinations = ["C:k", "c:K", "S:+r", "s:-P"]
  invalid_combinations.each do |qpi|
    raise "#{qpi} should be invalid" if Sashite::Qpi.valid?(qpi)
  end
end

# Test cross-style scenarios
run_test("Cross-style identifier scenarios") do
  chess_white = Sashite::Qpi.parse("C:K")
  chess_black = Sashite::Qpi.parse("c:k")
  shogi_white = Sashite::Qpi.parse("S:K")
  shogi_black = Sashite::Qpi.parse("s:k")

  # Same style comparisons
  raise "Chess pieces should be same style" unless chess_white.same_style?(chess_black)
  raise "Shogi pieces should be same style" unless shogi_white.same_style?(shogi_black)

  # Cross style comparisons
  raise "Chess and Shogi should be cross style" unless chess_white.cross_style?(shogi_white)
  raise "Chess and Shogi should be cross style" unless chess_black.cross_style?(shogi_black)
  raise "Chess and Shogi should be cross style" unless chess_white.cross_style?(shogi_black)
  raise "Chess and Shogi should be cross style" unless chess_black.cross_style?(shogi_white)
end

# Test valid? method consistency
run_test("Identifier valid? method consistency") do
  # Valid identifiers should return true
  valid_identifier = Sashite::Qpi::Identifier.new("C", "K")
  raise "valid identifier should return true for valid?" unless valid_identifier.valid?

  # Create identifiers that would be semantically inconsistent if constructed directly
  # Since constructor validates, we'll test the valid? method logic
  identifier = Sashite::Qpi::Identifier.new("C", "K")
  raise "semantic consistency should be true" unless identifier.valid?
end

# Test edge cases with all letters
run_test("All 26 ASCII letters work correctly in QPI") do
  letters = ("A".."Z").to_a

  letters.each do |letter|
    # Test first player
    qpi1 = "#{letter}:#{letter}"
    identifier1 = Sashite::Qpi.parse(qpi1)
    raise "#{letter} first player should parse correctly" unless identifier1.style.to_s == letter

    # Test second player
    qpi2 = "#{letter.downcase}:#{letter.downcase}"
    identifier2 = Sashite::Qpi.parse(qpi2)
    raise "#{letter.downcase} second player should parse correctly" unless identifier2.style.to_s == letter.downcase

    # Test same style
    raise "#{letter} pieces should be same style" unless identifier1.same_style?(identifier2)

    # Test different sides
    raise "#{letter} pieces should be different sides" if identifier1.same_side?(identifier2)
  end
end

# Test roundtrip parsing
run_test("Roundtrip parsing consistency") do
  test_cases = [
    ["C", "K"],
    ["c", "k"],
    ["S", "+R"],
    ["s", "-p"],
    ["X", "+G"],
    ["m", "-m"]
  ]

  test_cases.each do |sin_str, pin_str|
    # Create identifier -> to_s -> parse -> compare
    original = Sashite::Qpi::Identifier.new(sin_str, pin_str)
    qpi_string = original.to_s
    parsed = Sashite::Qpi.parse(qpi_string)

    raise "Roundtrip failed: original != parsed" unless original == parsed
    raise "Roundtrip failed: different sin" unless original.sin == parsed.sin
    raise "Roundtrip failed: different pin" unless original.pin == parsed.pin
    raise "Roundtrip failed: different components" unless original.to_sin == parsed.to_sin && original.to_pin == parsed.to_pin
  end
end

# Test performance
run_test("Performance - repeated operations") do
  # Test performance with many repeated calls
  1000.times do
    identifier = Sashite::Qpi.identifier("C", "K")
    enhanced = identifier.enhance
    flipped = identifier.flip_side
    different_style = identifier.with_style(:S)

    raise "Performance test failed" unless Sashite::Qpi.valid?("C:K")
    raise "Performance test failed" unless enhanced.enhanced?
    raise "Performance test failed" unless flipped.second_player?
    raise "Performance test failed" unless different_style.style == :S
  end
end

# Test constants
run_test("Identifier class constants are properly defined") do
  identifier_class = Sashite::Qpi::Identifier

  # Test separator
  raise "SEPARATOR should be ':'" unless identifier_class::SEPARATOR == ":"
end

puts
puts "All QPI tests passed!"
puts
