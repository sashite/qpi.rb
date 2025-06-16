# frozen_string_literal: true

require "simplecov"
SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Gan::Actor (General Actor Notation Actor)
#
# Tests the Actor class implementation for Ruby, covering actor creation,
# parsing, state manipulation, ownership changes, and format compliance
# according to the GAN specification v1.0.0.
#
# This test assumes the existence of:
# - lib/sashite-gan.rb

require_relative "../../../lib/sashite-gan"

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
puts "Tests for Sashite::Gan::Actor (General Actor Notation Actor)"
puts

# Test Actor creation with strings
run_test("Actor creation with string parameters") do
  actor = Sashite::Gan::Actor.new("CHESS", "K")

  raise "Should create actor" unless actor.is_a?(Sashite::Gan::Actor)
  raise "Should have correct style name" unless actor.style_name == "CHESS"
  raise "Should have correct piece name" unless actor.piece_name == "K"
  raise "Should convert to correct GAN string" unless actor.to_s == "CHESS:K"
end

run_test("Actor creation with object parameters") do
  style = Sashite::Snn::Style.new("CHESS")
  piece = Pnn::Piece.new("K")
  actor = Sashite::Gan::Actor.new(style, piece)

  raise "Should create actor" unless actor.is_a?(Sashite::Gan::Actor)
  raise "Should have correct style object" unless actor.style == style
  raise "Should have correct piece object" unless actor.piece == piece
  raise "Should convert to correct GAN string" unless actor.to_s == "CHESS:K"
end

run_test("Actor creation with mixed parameter types") do
  style_obj = Sashite::Snn::Style.new("CHESS")
  piece_str = "K"
  actor1 = Sashite::Gan::Actor.new(style_obj, piece_str)

  style_str = "SHOGI"
  piece_obj = Pnn::Piece.new("P")
  actor2 = Sashite::Gan::Actor.new(style_str, piece_obj)

  raise "Should create actor with style object and piece string" unless actor1.to_s == "CHESS:K"
  raise "Should create actor with style string and piece object" unless actor2.to_s == "SHOGI:P"
end

run_test("Actor creation rejects invalid parameters") do
  invalid_combinations = [
    ["", "K"],           # Invalid style
    ["CHESS", ""],       # Invalid piece
    ["Chess", "K"],      # Invalid style (mixed case)
    ["CHESS", "KK"],     # Invalid piece (multiple letters)
    ["CHESS-960", "K"],  # Invalid style (hyphen)
    ["CHESS", "++K"]     # Invalid piece (double prefix)
  ]

  invalid_combinations.each do |style, piece|
    Sashite::Gan::Actor.new(style, piece)
    raise "Should have raised ArgumentError for #{style.inspect}, #{piece.inspect}"
  rescue ArgumentError
    # Expected behavior
  end
end

# Test Actor parsing
run_test("Actor parsing with valid GAN strings") do
  valid_gans = [
    "CHESS:K", "chess:k", "SHOGI:P", "shogi:p",
    "CHESS:+P", "shogi:+p", "CHESS:K'", "shogi:p'",
    "CHESS:+K'", "shogi:-p'", "XIANGQI:r", "makruk:Q"
  ]

  valid_gans.each do |gan_string|
    actor = Sashite::Gan::Actor.parse(gan_string)
    raise "Should parse #{gan_string}" unless actor.is_a?(Sashite::Gan::Actor)
    raise "Should round-trip correctly for #{gan_string}" unless actor.to_s == gan_string
  end
end

run_test("Actor parsing rejects invalid GAN strings") do
  invalid_gans = [
    "", "CHESS", ":K", "CHESS:", "Chess:K", "CHESS:KK",
    "CHESS::K", "CHESS K", "CHESS:++K", "CHESS:K''"
  ]

  invalid_gans.each do |gan_string|
    Sashite::Gan::Actor.parse(gan_string)
    raise "Should have raised ArgumentError for #{gan_string.inspect}"
  rescue ArgumentError
    # Expected behavior
  end
end

# Test component access methods
run_test("Style and piece component access") do
  actor = Sashite::Gan::Actor.parse("CHESS:+K'")

  # Test object access
  raise "Style should be Snn::Style object" unless actor.style.is_a?(Sashite::Snn::Style)
  raise "Piece should be Pnn::Piece object" unless actor.piece.is_a?(Pnn::Piece)

  # Test string access
  raise "Style name should be CHESS" unless actor.style_name == "CHESS"
  raise "Piece name should be +K'" unless actor.piece_name == "+K'"

  # Test component properties
  raise "Style should be first player" unless actor.style.first_player?
  raise "Piece should be uppercase" unless actor.piece.uppercase?
  raise "Piece should be enhanced" unless actor.piece.enhanced?
  raise "Piece should be intermediate" unless actor.piece.intermediate?
end

# Test all four casing combinations
run_test("All four casing combinations") do
  combinations = [
    { gan: "CHESS:K", style_first: true, piece_upper: true },   # First player style, first player piece
    { gan: "CHESS:k", style_first: true, piece_upper: false },  # First player style, second player piece
    { gan: "chess:K", style_first: false, piece_upper: true },  # Second player style, first player piece
    { gan: "chess:k", style_first: false, piece_upper: false }  # Second player style, second player piece
  ]

  combinations.each do |combo|
    actor = Sashite::Gan::Actor.parse(combo[:gan])

    if combo[:style_first]
      raise "#{combo[:gan]} style should be first player" unless actor.style.first_player?
    else
      raise "#{combo[:gan]} style should be second player" unless actor.style.second_player?
    end

    if combo[:piece_upper]
      raise "#{combo[:gan]} piece should be uppercase" unless actor.piece.uppercase?
    else
      raise "#{combo[:gan]} piece should be lowercase" unless actor.piece.lowercase?
    end
  end
end

# Test piece state manipulation methods
run_test("Enhance piece method") do
  actor = Sashite::Gan::Actor.parse("SHOGI:P")
  enhanced = actor.enhance_piece

  raise "Should return new Actor instance" unless enhanced.is_a?(Sashite::Gan::Actor)
  raise "Original should be unchanged" unless actor.to_s == "SHOGI:P"
  raise "Enhanced should have + modifier" unless enhanced.to_s == "SHOGI:+P"
  raise "Should preserve style" unless enhanced.style_name == "SHOGI"
end

run_test("Diminish piece method") do
  actor = Sashite::Gan::Actor.parse("CHESS:R")
  diminished = actor.diminish_piece

  raise "Should return new Actor instance" unless diminished.is_a?(Sashite::Gan::Actor)
  raise "Original should be unchanged" unless actor.to_s == "CHESS:R"
  raise "Diminished should have - modifier" unless diminished.to_s == "CHESS:-R"
  raise "Should preserve style" unless diminished.style_name == "CHESS"
end

run_test("Set piece intermediate method") do
  actor = Sashite::Gan::Actor.parse("CHESS:K")
  intermediate = actor.set_piece_intermediate

  raise "Should return new Actor instance" unless intermediate.is_a?(Sashite::Gan::Actor)
  raise "Original should be unchanged" unless actor.to_s == "CHESS:K"
  raise "Intermediate should have ' suffix" unless intermediate.to_s == "CHESS:K'"
  raise "Should preserve style" unless intermediate.style_name == "CHESS"
end

run_test("Bare piece method") do
  actor = Sashite::Gan::Actor.parse("SHOGI:+P'")
  bare = actor.bare_piece

  raise "Should return new Actor instance" unless bare.is_a?(Sashite::Gan::Actor)
  raise "Original should be unchanged" unless actor.to_s == "SHOGI:+P'"
  raise "Bare should have no modifiers" unless bare.to_s == "SHOGI:P"
  raise "Should preserve style" unless bare.style_name == "SHOGI"
end

run_test("Change piece ownership method") do
  actor = Sashite::Gan::Actor.parse("SHOGI:P")
  captured = actor.change_piece_ownership

  raise "Should return new Actor instance" unless captured.is_a?(Sashite::Gan::Actor)
  raise "Original should be unchanged" unless actor.to_s == "SHOGI:P"
  raise "Captured should flip piece case" unless captured.to_s == "SHOGI:p"
  raise "Should preserve style" unless captured.style_name == "SHOGI"
end

run_test("Change piece ownership preserves modifiers") do
  actor = Sashite::Gan::Actor.parse("SHOGI:+P'")
  captured = actor.change_piece_ownership

  raise "Should preserve modifiers" unless captured.to_s == "SHOGI:+p'"
  raise "Should flip only the piece case" unless captured.piece.lowercase?
  raise "Should keep enhanced state" unless captured.piece.enhanced?
  raise "Should keep intermediate state" unless captured.piece.intermediate?
end

# Test state manipulation chaining
run_test("State manipulation method chaining") do
  actor = Sashite::Gan::Actor.parse("SHOGI:P")

  # Chain multiple operations
  complex = actor.enhance_piece.set_piece_intermediate
  raise "Should chain enhance and intermediate" unless complex.to_s == "SHOGI:+P'"

  # Test different chains
  flipped_enhanced = actor.change_piece_ownership.enhance_piece
  raise "Should chain ownership change and enhance" unless flipped_enhanced.to_s == "SHOGI:+p"

  # Test explicit modifier removal during ownership change
  enhanced = Sashite::Gan::Actor.parse("SHOGI:+P'")
  bare_captured = enhanced.bare_piece.change_piece_ownership
  raise "Should remove modifiers then change ownership" unless bare_captured.to_s == "SHOGI:p"

  # Alternative order
  captured_bare = enhanced.change_piece_ownership.bare_piece
  raise "Should change ownership then remove modifiers" unless captured_bare.to_s == "SHOGI:p"
end

# Test cross-style scenarios
run_test("Cross-style game actors") do
  chess_king = Sashite::Gan::Actor.parse("CHESS:K")
  makruk_king = Sashite::Gan::Actor.parse("makruk:k")

  raise "Chess king should be first player style" unless chess_king.style.first_player?
  raise "Makruk king should be second player style" unless makruk_king.style.second_player?
  raise "Chess piece should be uppercase" unless chess_king.piece.uppercase?
  raise "Makruk piece should be lowercase" unless makruk_king.piece.lowercase?

  # Verify they're different actors
  raise "Should be different actors" unless chess_king != makruk_king
end

run_test("Traditional same-style game actors") do
  white_king = Sashite::Gan::Actor.parse("CHESS:K")
  black_king = Sashite::Gan::Actor.parse("chess:k")

  raise "White should use uppercase style" unless white_king.style.first_player?
  raise "Black should use lowercase style" unless black_king.style.second_player?
  raise "White piece should be uppercase" unless white_king.piece.uppercase?
  raise "Black piece should be lowercase" unless black_king.piece.lowercase?

  # Verify they're different actors despite same piece type
  raise "Should be different actors" unless white_king != black_king
end

# Test collision resolution
run_test("Collision resolution between similar pieces") do
  similar_rooks = [
    Sashite::Gan::Actor.parse("CHESS:R"),
    Sashite::Gan::Actor.parse("SHOGI:R"),
    Sashite::Gan::Actor.parse("MAKRUK:R"),
    Sashite::Gan::Actor.parse("xiangqi:r")
  ]

  # All should be unique
  unique_actors = similar_rooks.uniq
  raise "All rook actors should be unique" unless similar_rooks.length == unique_actors.length

  # All should have different string representations
  strings = similar_rooks.map(&:to_s)
  unique_strings = strings.uniq
  raise "All GAN strings should be unique" unless strings.length == unique_strings.length
end

# Test equality and hashing
run_test("Equality comparison") do
  actor1 = Sashite::Gan::Actor.parse("CHESS:K")
  actor2 = Sashite::Gan::Actor.parse("CHESS:K")
  actor3 = Sashite::Gan::Actor.parse("chess:k")
  actor4 = Sashite::Gan::Actor.parse("CHESS:Q")

  raise "Same actors should be equal" unless actor1 == actor2
  raise "Same actors should be eql" unless actor1.eql?(actor2)
  raise "Different case actors should not be equal" if actor1 == actor3
  raise "Different piece actors should not be equal" if actor1 == actor4
  raise "Different objects should not be equal" if actor1 == "CHESS:K"
end

run_test("Hash behavior") do
  actor1 = Sashite::Gan::Actor.parse("CHESS:K")
  actor2 = Sashite::Gan::Actor.parse("CHESS:K")
  actor3 = Sashite::Gan::Actor.parse("chess:k")

  hash = { actor1 => "white_king" }
  hash[actor2] = "still_white_king"
  hash[actor3] = "black_king"

  raise "Same actors should have same hash" unless actor1.hash == actor2.hash
  raise "Hash should have 2 entries" unless hash.size == 2
  raise "Should retrieve by equivalent actor" unless hash[actor2] == "still_white_king"
end

# Test immutability
run_test("Actor immutability") do
  actor = Sashite::Gan::Actor.parse("CHESS:K")

  raise "Actor should be frozen" unless actor.frozen?

  # Test that component access returns frozen objects
  raise "Style should be frozen" unless actor.style.frozen?
  raise "Piece should be frozen" unless actor.piece.frozen?
end

run_test("State manipulation immutability") do
  actor = Sashite::Gan::Actor.parse("CHESS:K")
  enhanced = actor.enhance_piece

  # Original should be unchanged
  raise "Original should be unchanged" unless actor.to_s == "CHESS:K"
  raise "Enhanced should be different" unless enhanced.to_s == "CHESS:+K"
  raise "Should be different objects" if actor.equal?(enhanced)
end

# Test inspect method
run_test("Inspect method") do
  actor = Sashite::Gan::Actor.parse("CHESS:+K'")
  inspect_string = actor.inspect

  raise "Inspect should include class name" unless inspect_string.include?("Sashite::Gan::Actor")
  raise "Inspect should include style" unless inspect_string.include?('"CHESS"')
  raise "Inspect should include piece" unless inspect_string.include?('"+K\'"')
  raise "Inspect should include object_id" unless inspect_string.include?("0x")
end

# Test advanced scenarios
run_test("Complex state manipulation scenarios") do
  # Shogi promotion and capture scenario
  pawn = Sashite::Gan::Actor.parse("SHOGI:P")
  promoted = pawn.enhance_piece # Promote to tokin
  captured = promoted.change_piece_ownership # Captured by opponent

  raise "Promoted pawn should be +P" unless promoted.to_s == "SHOGI:+P"
  raise "Captured promoted should preserve modifiers" unless captured.to_s == "SHOGI:+p"

  # If game rules require modifier removal on capture
  bare_captured = promoted.bare_piece.change_piece_ownership
  raise "Bare captured should remove modifiers" unless bare_captured.to_s == "SHOGI:p"
end

run_test("Chess castling rights scenario") do
  # Rook that can still castle
  rook = Sashite::Gan::Actor.parse("CHESS:R'")

  # After moving (loses castling rights)
  moved_rook = rook.bare_piece
  raise "Moved rook should lose intermediate state" unless moved_rook.to_s == "CHESS:R"

  # If captured while maintaining state
  captured_rook = rook.change_piece_ownership
  raise "Captured rook should preserve state" unless captured_rook.to_s == "CHESS:r'"
end

run_test("En passant scenario") do
  # Pawn vulnerable to en passant
  pawn = Sashite::Gan::Actor.parse("CHESS:-P")

  # After opponent's turn (no longer vulnerable)
  safe_pawn = pawn.bare_piece
  raise "Safe pawn should lose intermediate state" unless safe_pawn.to_s == "CHESS:P"

  # If captured en passant
  captured_pawn = pawn.change_piece_ownership.bare_piece
  raise "Captured pawn should be bare" unless captured_pawn.to_s == "CHESS:p"
end

# Test variant styles with actors
run_test("Chess variant actors") do
  variants = [
    "CHESS960:K", "chess960:k",     # Fischer Random
    "CHESSKING:Q", "chessking:q",   # King of the Hill
    "MINISHOGI:G", "minishogi:g"    # Mini Shogi
  ]

  variants.each do |gan_string|
    actor = Sashite::Gan::Actor.parse(gan_string)
    raise "Should parse variant #{gan_string}" unless actor.to_s == gan_string

    # Test that they work with state manipulation
    enhanced = actor.enhance_piece
    raise "Variants should support enhancement" unless enhanced.piece.enhanced?
  end
end

# Test edge cases with single characters
run_test("Single character edge cases") do
  edge_actors = [
    "A:A", "a:a", "Z:Z", "z:z",
    "A:+B", "a:-b", "Z:C'", "z:+d'"
  ]

  edge_actors.each do |gan_string|
    actor = Sashite::Gan::Actor.parse(gan_string)
    raise "Should handle edge case #{gan_string}" unless actor.to_s == gan_string

    # Test state manipulation works
    flipped = actor.change_piece_ownership
    raise "Edge case should support ownership change" unless flipped != actor
  end
end

# Test alphanumeric styles
run_test("Alphanumeric style actors") do
  alphanumeric_actors = [
    "A1:K", "a1:k", "B2:Q", "b2:q",
    "X9:P", "x9:p", "Z123:+R'", "z123:-r'"
  ]

  alphanumeric_actors.each do |gan_string|
    actor = Sashite::Gan::Actor.parse(gan_string)
    raise "Should handle alphanumeric #{gan_string}" unless actor.to_s == gan_string

    # Verify style parsing
    raise "Style should be parsed correctly" unless actor.style_name == gan_string.split(":").first
  end
end

# Test comprehensive ownership change scenarios
run_test("Comprehensive ownership change scenarios") do
  test_cases = [
    { original: "CHESS:K", expected: "CHESS:k" },
    { original: "chess:k", expected: "chess:K" },
    { original: "SHOGI:+P", expected: "SHOGI:+p" },
    { original: "shogi:+p", expected: "shogi:+P" },
    { original: "CHESS:R'", expected: "CHESS:r'" },
    { original: "chess:r'", expected: "chess:R'" },
    { original: "XIANGQI:+r'", expected: "XIANGQI:+R'" },
    { original: "xiangqi:+R'", expected: "xiangqi:+r'" }
  ]

  test_cases.each do |test_case|
    actor = Sashite::Gan::Actor.parse(test_case[:original])
    changed = actor.change_piece_ownership

    raise "#{test_case[:original]} should become #{test_case[:expected]}, got #{changed}" unless changed.to_s == test_case[:expected]
  end
end

# Test method chaining robustness
run_test("Method chaining robustness") do
  actor = Sashite::Gan::Actor.parse("SHOGI:P")

  # Complex chaining
  result1 = actor.enhance_piece.set_piece_intermediate.change_piece_ownership
  raise "Complex chain 1 failed" unless result1.to_s == "SHOGI:+p'"

  result2 = actor.change_piece_ownership.enhance_piece.set_piece_intermediate
  raise "Complex chain 2 failed" unless result2.to_s == "SHOGI:+p'"

  result3 = actor.set_piece_intermediate.enhance_piece.change_piece_ownership
  raise "Complex chain 3 failed" unless result3.to_s == "SHOGI:+p'"

  # Verify all intermediate steps create new objects
  step1 = actor.enhance_piece
  step2 = step1.set_piece_intermediate
  step3 = step2.change_piece_ownership

  objects = [actor, step1, step2, step3]
  object_ids = objects.map(&:object_id)
  unique_ids = object_ids.uniq

  raise "All steps should create new objects" unless objects.length == unique_ids.length
end

# Test that state changes don't affect components inappropriately
run_test("Component isolation during state changes") do
  actor = Sashite::Gan::Actor.parse("CHESS:K")
  original_style = actor.style
  original_piece = actor.piece

  # Various state changes
  enhanced = actor.enhance_piece
  captured = actor.change_piece_ownership
  intermediate = actor.set_piece_intermediate

  # Original components should be unchanged
  raise "Original style should be unchanged" unless actor.style == original_style
  raise "Original piece should be unchanged" unless actor.piece == original_piece

  # Style should be preserved in all modifications
  raise "Enhanced should preserve style" unless enhanced.style == original_style
  raise "Captured should preserve style" unless captured.style == original_style
  raise "Intermediate should preserve style" unless intermediate.style == original_style

  # Only piece should change appropriately
  raise "Enhanced piece should be different" unless enhanced.piece != original_piece
  raise "Captured piece should be different" unless captured.piece != original_piece
  raise "Intermediate piece should be different" unless intermediate.piece != original_piece
end

# Test error handling in edge cases
run_test("Error handling edge cases") do
  # Test with objects that might cause issues
  actor = Sashite::Gan::Actor.parse("CHESS:K")

  # Verify that all state manipulation methods return proper actors
  methods_to_test = %i[
    enhance_piece diminish_piece set_piece_intermediate
    bare_piece change_piece_ownership
  ]

  methods_to_test.each do |method|
    result = actor.public_send(method) # rubocop:disable GitlabSecurity/PublicSend
    raise "#{method} should return Actor" unless result.is_a?(Sashite::Gan::Actor)
    raise "#{method} should return valid GAN" unless Sashite::Gan.valid?(result.to_s)
    raise "#{method} should return frozen object" unless result.frozen?
  end
end

puts
puts "All Actor tests passed!"
puts
