# frozen_string_literal: true

# Tests for Sashite::Gan (General Actor Notation)
#
# Tests the GAN implementation for Ruby, focusing on the modern object-oriented API
# with the Actor class using symbol-based attributes and the minimal module interface.
# Tests integration between SNN and PIN components with case consistency validation.

require_relative "lib/sashite-gan"
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
puts "Tests for Sashite::Gan (General Actor Notation)"
puts

# Test basic validation (module level)
run_test("Module GAN validation accepts valid notations") do
  valid_gans = [
    "CHESS:K", "chess:k", "SHOGI:P", "shogi:p", "XIANGQI:G", "xiangqi:g",
    "CHESS:+R", "chess:+r", "SHOGI:-P", "shogi:-p",
    "CHESS960:K", "chess960:k", "KOTH:Q", "koth:q",
    "A:A", "a:a", "Z:Z", "z:z", "ABC123:+A", "abc123:-z"
  ]

  valid_gans.each do |gan|
    raise "#{gan.inspect} should be valid" unless Sashite::Gan.valid?(gan)
  end
end

run_test("Module GAN validation rejects invalid notations") do
  invalid_gans = [
    "", "CHESS", ":K", "CHESS:", "CHESS:KK", "CHESS::K",
    "Chess:K", "CHESS:k", "chess:K", "CHESS:+k", "chess:+K",
    "CHESS-960:K", "CHESS_960:K", "CHESS 960:K", "CHESS:K+",
    "CHESS:++K", "CHESS:--K", "CHESS:+-K", "CHESS:-+K",
    "123:K", "CHESS:123", "!:K", "CHESS:!", "@:@", "#:#"
  ]

  invalid_gans.each do |gan|
    raise "#{gan.inspect} should be invalid" if Sashite::Gan.valid?(gan)
  end
end

run_test("Module GAN validation handles non-string input") do
  non_strings = [nil, 123, :chess, [], {}, true, false, 1.5]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Gan.valid?(input)
  end
end

# Test module parse method delegates to Actor
run_test("Module parse delegates to Actor class") do
  gan_string = "CHESS:K"
  actor = Sashite::Gan.parse(gan_string)

  raise "parse should return Actor instance" unless actor.is_a?(Sashite::Gan::Actor)
  raise "actor should have correct GAN string" unless actor.to_s == gan_string
end

# Test module actor factory method
run_test("Module actor factory method creates correct instances") do
  actor = Sashite::Gan.actor(:Chess, :K, :first, :enhanced)

  raise "actor factory should return Actor instance" unless actor.is_a?(Sashite::Gan::Actor)
  raise "actor should have correct name" unless actor.name == :Chess
  raise "actor should have correct type" unless actor.type == :K
  raise "actor should have correct side" unless actor.side == :first
  raise "actor should have correct state" unless actor.state == :enhanced
  raise "actor should have correct GAN string" unless actor.to_s == "CHESS:+K"
end

# Test Actor class valid? method
run_test("Actor.valid? accepts valid notations") do
  valid_gans = [
    "CHESS:K", "chess:k", "SHOGI:+P", "shogi:-p", "XIANGQI:G", "xiangqi:g"
  ]

  valid_gans.each do |gan|
    raise "#{gan.inspect} should be valid" unless Sashite::Gan::Actor.valid?(gan)
  end
end

run_test("Actor.valid? rejects invalid notations") do
  invalid_gans = [
    "", "CHESS", "Chess:K", "CHESS:k", "chess:K", "CHESS:+k", "chess:+K"
  ]

  invalid_gans.each do |gan|
    raise "#{gan.inspect} should be invalid" if Sashite::Gan::Actor.valid?(gan)
  end
end

run_test("Actor.valid? validates case consistency") do
  # Valid case consistency
  valid_cases = [
    "CHESS:K", "chess:k", "SHOGI:+R", "shogi:-p"
  ]

  valid_cases.each do |gan|
    raise "#{gan.inspect} should be valid (case consistent)" unless Sashite::Gan::Actor.valid?(gan)
  end

  # Invalid case consistency
  invalid_cases = [
    "CHESS:k", "chess:K", "SHOGI:+r", "shogi:-P"
  ]

  invalid_cases.each do |gan|
    raise "#{gan.inspect} should be invalid (case mismatch)" if Sashite::Gan::Actor.valid?(gan)
  end
end

# Test the Actor class with new symbol-based API
run_test("Actor.parse creates correct instances with symbol attributes") do
  test_cases = {
    "CHESS:K" => { name: :Chess, type: :K, side: :first, state: :normal },
    "chess:k" => { name: :Chess, type: :K, side: :second, state: :normal },
    "SHOGI:+P" => { name: :Shogi, type: :P, side: :first, state: :enhanced },
    "xiangqi:-g" => { name: :Xiangqi, type: :G, side: :second, state: :diminished }
  }

  test_cases.each do |gan_string, expected|
    actor = Sashite::Gan.parse(gan_string)

    raise "#{gan_string}: wrong name" unless actor.name == expected[:name]
    raise "#{gan_string}: wrong type" unless actor.type == expected[:type]
    raise "#{gan_string}: wrong side" unless actor.side == expected[:side]
    raise "#{gan_string}: wrong state" unless actor.state == expected[:state]
  end
end

run_test("Actor constructor with symbol parameters") do
  test_cases = [
    [:Chess, :K, :first, :normal, "CHESS:K"],
    [:Chess, :K, :second, :normal, "chess:k"],
    [:Shogi, :P, :first, :enhanced, "SHOGI:+P"],
    [:Xiangqi, :G, :second, :diminished, "xiangqi:-g"]
  ]

  test_cases.each do |name, type, side, state, expected_gan|
    actor = Sashite::Gan::Actor.new(name, type, side, state)

    raise "name should be #{name}" unless actor.name == name
    raise "type should be #{type}" unless actor.type == type
    raise "side should be #{side}" unless actor.side == side
    raise "state should be #{state}" unless actor.state == state
    raise "GAN string should be #{expected_gan}" unless actor.to_s == expected_gan
  end
end

run_test("Actor to_s returns correct GAN string") do
  test_cases = [
    [:Chess, :K, :first, :normal, "CHESS:K"],
    [:Chess, :K, :second, :normal, "chess:k"],
    [:Shogi, :P, :first, :enhanced, "SHOGI:+P"],
    [:Xiangqi, :G, :second, :diminished, "xiangqi:-g"]
  ]

  test_cases.each do |name, type, side, state, expected|
    actor = Sashite::Gan::Actor.new(name, type, side, state)
    result = actor.to_s

    raise "#{name}, #{type}, #{side}, #{state} should be #{expected}, got #{result}" unless result == expected
  end
end

run_test("Actor to_pin and to_snn methods") do
  test_cases = [
    ["CHESS:K", "CHESS", "K"],
    ["chess:k", "chess", "k"],
    ["SHOGI:+P", "SHOGI", "+P"],
    ["xiangqi:-g", "xiangqi", "-g"]
  ]

  test_cases.each do |gan_string, expected_snn, expected_pin|
    actor = Sashite::Gan.parse(gan_string)

    raise "#{gan_string}: wrong to_snn" unless actor.to_snn == expected_snn
    raise "#{gan_string}: wrong to_pin" unless actor.to_pin == expected_pin
    raise "#{gan_string}: to_s should equal to_snn:to_pin" unless actor.to_s == "#{actor.to_snn}:#{actor.to_pin}"
  end
end

run_test("Actor state mutations return new instances") do
  actor = Sashite::Gan::Actor.new(:Chess, :K, :first, :normal)

  # Test enhance
  enhanced = actor.enhance
  raise "enhance should return new instance" if enhanced.equal?(actor)
  raise "enhanced actor should be enhanced" unless enhanced.enhanced?
  raise "enhanced actor state should be :enhanced" unless enhanced.state == :enhanced
  raise "original actor should be unchanged" unless actor.state == :normal
  raise "enhanced actor should have same name, type, and side" unless enhanced.name == actor.name && enhanced.type == actor.type && enhanced.side == actor.side

  # Test diminish
  diminished = actor.diminish
  raise "diminish should return new instance" if diminished.equal?(actor)
  raise "diminished actor should be diminished" unless diminished.diminished?
  raise "diminished actor state should be :diminished" unless diminished.state == :diminished
  raise "original actor should be unchanged" unless actor.state == :normal

  # Test flip
  flipped = actor.flip
  raise "flip should return new instance" if flipped.equal?(actor)
  raise "flipped actor should have opposite side" unless flipped.side == :second
  raise "flipped actor should have same name, type, and state" unless flipped.name == actor.name && flipped.type == actor.type && flipped.state == actor.state
  raise "original actor should be unchanged" unless actor.side == :first
end

run_test("Actor attribute transformations") do
  actor = Sashite::Gan::Actor.new(:Chess, :K, :first, :normal)

  # Test with_name
  shogi = actor.with_name(:Shogi)
  raise "with_name should return new instance" if shogi.equal?(actor)
  raise "new actor should have different name" unless shogi.name == :Shogi
  raise "new actor should have same type, side, and state" unless shogi.type == actor.type && shogi.side == actor.side && shogi.state == actor.state

  # Test with_type
  queen = actor.with_type(:Q)
  raise "with_type should return new instance" if queen.equal?(actor)
  raise "new actor should have different type" unless queen.type == :Q
  raise "new actor should have same name, side, and state" unless queen.name == actor.name && queen.side == actor.side && queen.state == actor.state

  # Test with_side
  black_king = actor.with_side(:second)
  raise "with_side should return new instance" if black_king.equal?(actor)
  raise "new actor should have different side" unless black_king.side == :second
  raise "new actor should have same name, type, and state" unless black_king.name == actor.name && black_king.type == actor.type && black_king.state == actor.state

  # Test with_state
  enhanced_king = actor.with_state(:enhanced)
  raise "with_state should return new instance" if enhanced_king.equal?(actor)
  raise "new actor should have different state" unless enhanced_king.state == :enhanced
  raise "new actor should have same name, type, and side" unless enhanced_king.name == actor.name && enhanced_king.type == actor.type && enhanced_king.side == actor.side
end

run_test("Actor immutability") do
  actor = Sashite::Gan::Actor.new(:Chess, :K, :first, :enhanced)

  # Test that actor is frozen
  raise "actor should be frozen" unless actor.frozen?

  # Test that mutations don't affect original
  original_string = actor.to_s
  normalized = actor.normalize

  raise "original actor should be unchanged after normalize" unless actor.to_s == original_string
  raise "normalized actor should be different" unless normalized.to_s == "CHESS:K"
end

run_test("Actor equality and hash") do
  actor1 = Sashite::Gan::Actor.new(:Chess, :K, :first, :normal)
  actor2 = Sashite::Gan::Actor.new(:Chess, :K, :first, :normal)
  actor3 = Sashite::Gan::Actor.new(:Chess, :K, :second, :normal)
  actor4 = Sashite::Gan::Actor.new(:Chess, :K, :first, :enhanced)

  # Test equality
  raise "identical actors should be equal" unless actor1 == actor2
  raise "different side should not be equal" if actor1 == actor3
  raise "different state should not be equal" if actor1 == actor4

  # Test hash consistency
  raise "equal actors should have same hash" unless actor1.hash == actor2.hash

  # Test in hash/set
  actors_set = Set.new([actor1, actor2, actor3, actor4])
  raise "set should contain 3 unique actors" unless actors_set.size == 3
end

run_test("Actor name, type, side, and state identification") do
  test_cases = [
    ["CHESS:K", :Chess, :K, :first, :normal, true, false],
    ["chess:k", :Chess, :K, :second, :normal, false, true],
    ["SHOGI:+P", :Shogi, :P, :first, :enhanced, true, false],
    ["xiangqi:-g", :Xiangqi, :G, :second, :diminished, false, true]
  ]

  test_cases.each do |gan_string, expected_name, expected_type, expected_side, expected_state, is_first, is_second|
    actor = Sashite::Gan.parse(gan_string)

    raise "#{gan_string}: wrong name" unless actor.name == expected_name
    raise "#{gan_string}: wrong type" unless actor.type == expected_type
    raise "#{gan_string}: wrong side" unless actor.side == expected_side
    raise "#{gan_string}: wrong state" unless actor.state == expected_state
    raise "#{gan_string}: wrong first_player?" unless actor.first_player? == is_first
    raise "#{gan_string}: wrong second_player?" unless actor.second_player? == is_second
  end
end

run_test("Actor same_name?, same_type?, same_side?, and same_state? methods") do
  chess1 = Sashite::Gan::Actor.new(:Chess, :K, :first, :normal)
  chess2 = Sashite::Gan::Actor.new(:Chess, :Q, :second, :enhanced)
  shogi1 = Sashite::Gan::Actor.new(:Shogi, :K, :first, :normal)
  shogi2 = Sashite::Gan::Actor.new(:Shogi, :P, :second, :enhanced)

  # same_name? tests
  raise "Chess and Chess should be same name" unless chess1.same_name?(chess2)
  raise "Chess and Shogi should not be same name" if chess1.same_name?(shogi1)

  # same_type? tests
  raise "K and K should be same type" unless chess1.same_type?(shogi1)
  raise "K and Q should not be same type" if chess1.same_type?(chess2)

  # same_side? tests
  raise "first player actors should be same side" unless chess1.same_side?(shogi1)
  raise "different side actors should not be same side" if chess1.same_side?(chess2)

  # same_state? tests
  raise "normal actors should be same state" unless chess1.same_state?(shogi1)
  raise "enhanced actors should be same state" unless chess2.same_state?(shogi2)
  raise "different state actors should not be same state" if chess1.same_state?(chess2)
end

run_test("Actor state methods") do
  normal = Sashite::Gan::Actor.new(:Chess, :K, :first, :normal)
  enhanced = Sashite::Gan::Actor.new(:Chess, :K, :first, :enhanced)
  diminished = Sashite::Gan::Actor.new(:Chess, :K, :first, :diminished)

  # Test state identification
  raise "normal actor should be normal" unless normal.normal?
  raise "normal actor should not be enhanced" if normal.enhanced?
  raise "normal actor should not be diminished" if normal.diminished?
  raise "normal actor state should be :normal" unless normal.state == :normal

  raise "enhanced actor should be enhanced" unless enhanced.enhanced?
  raise "enhanced actor should not be normal" if enhanced.normal?
  raise "enhanced actor state should be :enhanced" unless enhanced.state == :enhanced

  raise "diminished actor should be diminished" unless diminished.diminished?
  raise "diminished actor should not be normal" if diminished.normal?
  raise "diminished actor state should be :diminished" unless diminished.state == :diminished
end

run_test("Actor transformation methods return self when appropriate") do
  normal_actor = Sashite::Gan::Actor.new(:Chess, :K, :first, :normal)
  enhanced_actor = Sashite::Gan::Actor.new(:Chess, :K, :first, :enhanced)
  diminished_actor = Sashite::Gan::Actor.new(:Chess, :K, :first, :diminished)

  # Test methods that should return self
  raise "normalize on normal actor should return self" unless normal_actor.normalize.equal?(normal_actor)
  raise "enhance on enhanced actor should return self" unless enhanced_actor.enhance.equal?(enhanced_actor)
  raise "diminish on diminished actor should return self" unless diminished_actor.diminish.equal?(diminished_actor)

  # Test with_* methods that should return self
  raise "with_name with same name should return self" unless normal_actor.with_name(:Chess).equal?(normal_actor)
  raise "with_type with same type should return self" unless normal_actor.with_type(:K).equal?(normal_actor)
  raise "with_side with same side should return self" unless normal_actor.with_side(:first).equal?(normal_actor)
  raise "with_state with same state should return self" unless normal_actor.with_state(:normal).equal?(normal_actor)
end

run_test("Actor transformation chains") do
  actor = Sashite::Gan::Actor.new(:Chess, :K, :first, :normal)

  # Test enhance then normalize
  enhanced = actor.enhance
  back_to_normal = enhanced.normalize
  raise "enhance then normalize should equal original" unless back_to_normal == actor

  # Test diminish then normalize
  diminished = actor.diminish
  back_to_normal2 = diminished.normalize
  raise "diminish then normalize should equal original" unless back_to_normal2 == actor

  # Test complex chain
  transformed = actor.flip.enhance.with_name(:Shogi).diminish
  raise "complex chain should work" unless transformed.to_s == "shogi:-k"
  raise "original should be unchanged" unless actor.to_s == "CHESS:K"
end

run_test("Actor error handling for invalid symbols") do
  # Invalid names
  invalid_names = [:invalid, :chess, :CHESS, "Chess", 1, nil]

  invalid_names.each do |name|
    begin
      Sashite::Gan::Actor.new(name, :K, :first, :normal)
      raise "Should have raised error for invalid name #{name.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid name" unless e.message.include?("Name must be")
    end
  end

  # Invalid types
  invalid_types = [:invalid, :k, :"1", :AA, "K", 1, nil]

  invalid_types.each do |type|
    begin
      Sashite::Gan::Actor.new(:Chess, type, :first, :normal)
      raise "Should have raised error for invalid type #{type.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid type" unless e.message.include?("Type must be")
    end
  end

  # Invalid sides
  invalid_sides = [:invalid, :player1, :white, "first", 1, nil]

  invalid_sides.each do |side|
    begin
      Sashite::Gan::Actor.new(:Chess, :K, side, :normal)
      raise "Should have raised error for invalid side #{side.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid side" unless e.message.include?("Side must be")
    end
  end

  # Invalid states
  invalid_states = [:invalid, :promoted, :active, "normal", 1, nil]

  invalid_states.each do |state|
    begin
      Sashite::Gan::Actor.new(:Chess, :K, :first, state)
      raise "Should have raised error for invalid state #{state.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid state" unless e.message.include?("State must be")
    end
  end
end

run_test("Actor error handling for invalid GAN strings") do
  # Invalid GAN strings
  invalid_gans = ["", "CHESS", "Chess:K", "CHESS:k", nil, :symbol]

  invalid_gans.each do |gan|
    begin
      Sashite::Gan.parse(gan)
      raise "Should have raised error for #{gan.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid GAN or case mismatch" unless e.message.include?("Invalid GAN") || e.message.include?("Case mismatch")
    end
  end
end

# Test case consistency validation
run_test("Case consistency validation") do
  # Valid case combinations
  valid_cases = [
    "CHESS:K", "chess:k", "SHOGI:+P", "shogi:-p", "XIANGQI:G", "xiangqi:g"
  ]

  valid_cases.each do |gan|
    raise "#{gan.inspect} should be valid (case consistent)" unless Sashite::Gan.valid?(gan)
  end

  # Invalid case combinations
  invalid_cases = [
    "CHESS:k", "chess:K", "SHOGI:+p", "shogi:-P", "XIANGQI:g", "xiangqi:G"
  ]

  invalid_cases.each do |gan|
    raise "#{gan.inspect} should be invalid (case mismatch)" if Sashite::Gan.valid?(gan)
  end
end

# Test component extraction and reconstruction
run_test("Component extraction and reconstruction") do
  test_cases = [
    "CHESS:K", "chess:k", "SHOGI:+P", "xiangqi:-g"
  ]

  test_cases.each do |gan_string|
    actor = Sashite::Gan.parse(gan_string)

    # Extract components
    snn_part = actor.to_snn
    pin_part = actor.to_pin

    # Reconstruct
    reconstructed = "#{snn_part}:#{pin_part}"

    raise "#{gan_string}: reconstruction failed" unless reconstructed == gan_string

    # Parse reconstructed string
    reparsed = Sashite::Gan.parse(reconstructed)

    raise "#{gan_string}: reparsed actor should equal original" unless reparsed == actor
  end
end

# Test game-specific examples
run_test("Chess style actors") do
  # Standard chess
  chess = Sashite::Gan.actor(:Chess, :K, :first, :normal)
  raise "Chess should be first player" unless chess.first_player?
  raise "Chess name should be :Chess" unless chess.name == :Chess
  raise "Chess GAN should be CHESS:K" unless chess.to_s == "CHESS:K"

  # Chess variants
  chess960 = Sashite::Gan.actor(:Chess960, :K, :first, :normal)
  raise "Chess960 name should be :Chess960" unless chess960.name == :Chess960
  raise "Chess960 GAN should be CHESS960:K" unless chess960.to_s == "CHESS960:K"

  koth = Sashite::Gan.actor(:Koth, :K, :first, :normal)
  raise "KOTH name should be :Koth" unless koth.name == :Koth
  raise "KOTH GAN should be KOTH:K" unless koth.to_s == "KOTH:K"
end

run_test("Shōgi style actors") do
  # Standard shōgi
  shogi = Sashite::Gan.actor(:Shogi, :K, :first, :normal)
  raise "Shogi should be first player" unless shogi.first_player?
  raise "Shogi name should be :Shogi" unless shogi.name == :Shogi
  raise "Shogi GAN should be SHOGI:K" unless shogi.to_s == "SHOGI:K"

  # Promoted pieces
  promoted_pawn = Sashite::Gan.actor(:Shogi, :P, :first, :enhanced)
  raise "Promoted pawn should be enhanced" unless promoted_pawn.enhanced?
  raise "Promoted pawn GAN should be SHOGI:+P" unless promoted_pawn.to_s == "SHOGI:+P"
end

run_test("Cross-style actor transformations") do
  # Test that actors can be transformed across different contexts
  actor = Sashite::Gan.actor(:Chess, :K, :first, :normal)

  # Chain transformations
  transformed = actor.flip.with_name(:Shogi).flip.with_name(:Xiangqi)
  expected_final = "XIANGQI:K"  # Should end up as first player Xiangqi

  raise "Chained transformation should work" unless transformed.to_s == expected_final
  raise "Original actor should be unchanged" unless actor.to_s == "CHESS:K"
end

# Test practical usage scenarios
run_test("Practical usage - actor collections") do
  actors = [
    Sashite::Gan.actor(:Chess, :K, :first, :normal),
    Sashite::Gan.actor(:Shogi, :K, :first, :normal),
    Sashite::Gan.actor(:Chess, :Q, :first, :enhanced),
    Sashite::Gan.actor(:Chess, :K, :second, :normal)
  ]

  # Filter by side
  first_player_actors = actors.select(&:first_player?)
  raise "Should have 3 first player actors" unless first_player_actors.size == 3

  # Group by name
  by_name = actors.group_by(&:name)
  raise "Should have chess actors grouped" unless by_name[:Chess].size == 3

  # Find specific actors
  chess_actors = actors.select { |a| a.name == :Chess }
  raise "Should have 3 chess actors" unless chess_actors.size == 3

  # Group by component strings
  by_snn = actors.group_by(&:to_snn)
  by_pin = actors.group_by(&:to_pin)

  raise "Should have CHESS and SHOGI styles" unless by_snn.key?("CHESS") && by_snn.key?("SHOGI")
  raise "Should have different PIN representations" unless by_pin.size > 1
end

run_test("Practical usage - game configuration") do
  # Simulate multi-style match setup
  white_style = Sashite::Gan.actor(:Chess, :K, :first, :normal)
  black_style = Sashite::Gan.actor(:Shogi, :K, :second, :normal)

  raise "White should be first player" unless white_style.first_player?
  raise "Black should be second player" unless black_style.second_player?
  raise "Styles should have different names" unless white_style.name != black_style.name
  raise "Styles should have different sides" unless !white_style.same_side?(black_style)

  # Test style switching
  switched = white_style.with_name(black_style.name)
  raise "Switched actor should have black's name" unless switched.name == black_style.name
  raise "Switched actor should keep white's side" unless switched.side == white_style.side
end

# Test edge cases
run_test("Edge case - alphanumeric identifiers") do
  alphanumeric_actors = [
    [:Chess960, :A, :first, :normal, "CHESS960:A"],
    [:A1, :Z, :second, :enhanced, "a1:+z"],
    [:Game123, :B, :first, :diminished, "GAME123:-B"]
  ]

  alphanumeric_actors.each do |name_symbol, type, side, state, expected_gan|
    actor = Sashite::Gan.actor(name_symbol, type, side, state)
    raise "#{name_symbol} should create valid actor" unless actor.name == name_symbol
    raise "#{name_symbol} should have correct type" unless actor.type == type
    raise "#{name_symbol} should have correct side" unless actor.side == side
    raise "#{name_symbol} should have correct state" unless actor.state == state
    raise "#{name_symbol} should display as #{expected_gan}" unless actor.to_s == expected_gan

    # Test component extraction
    raise "#{name_symbol} to_snn should work" unless actor.to_snn.length > 0
    raise "#{name_symbol} to_pin should work" unless actor.to_pin.length > 0
  end
end

run_test("Edge case - name normalization from various input cases") do
  test_cases = [
    ["CHESS:K", :Chess],
    ["chess:k", :Chess],
    ["SHOGI:P", :Shogi],
    ["shogi:p", :Shogi],
    ["XIANGQI:G", :Xiangqi],
    ["xiangqi:g", :Xiangqi]
  ]

  test_cases.each do |input, expected_name|
    actor = Sashite::Gan.parse(input)
    raise "#{input} should normalize to #{expected_name}" unless actor.name == expected_name
  end
end

run_test("Edge case - unicode and special characters still invalid") do
  unicode_chars = ["α:α", "β:β", "♕:♔", "🀄:🀄", "象:將", "CHESS:♕"]

  unicode_chars.each do |char|
    raise "#{char.inspect} should be invalid (not ASCII)" if Sashite::Gan.valid?(char)
  end
end

run_test("Edge case - whitespace handling still works") do
  whitespace_cases = [
    " CHESS:K", "CHESS:K ", " chess:k", "chess:k ",
    "\tCHESS:K", "CHESS:K\t", "\nchess:k", "chess:k\n", " CHESS:K ", "\tchess:k\t",
    "CHESS: K", "CHESS :K", " CHESS : K "
  ]

  whitespace_cases.each do |gan|
    raise "#{gan.inspect} should be invalid (whitespace)" if Sashite::Gan.valid?(gan)
  end
end

run_test("Edge case - mixed case still invalid") do
  mixed_cases = ["Chess:K", "CHESS:k", "chess:K", "ChEsS:K", "CHESS:ChEsS"]

  mixed_cases.each do |gan|
    raise "#{gan.inspect} should be invalid (mixed case)" if Sashite::Gan.valid?(gan)
  end
end

run_test("Edge case - malformed separators") do
  malformed_separators = [
    "CHESS::K", "CHESS:::K", "CHESS", ":K", "CHESS:",
    "CHESS;K", "CHESS K", "CHESS.K", "CHESS|K"
  ]

  malformed_separators.each do |gan|
    raise "#{gan.inspect} should be invalid (malformed separator)" if Sashite::Gan.valid?(gan)
  end
end

# Test component delegation
run_test("Component validation delegates to SNN and PIN") do
  # Test that GAN validation uses the same patterns as individual components
  test_cases = [
    ["CHESS", "K"],
    ["chess", "k"],
    ["SHOGI", "+P"],
    ["xiangqi", "-g"]
  ]

  test_cases.each do |snn_part, pin_part|
    # Individual components should be valid
    raise "#{snn_part} should be valid SNN" unless Sashite::Snn.valid?(snn_part)
    raise "#{pin_part} should be valid PIN" unless Sashite::Pin.valid?(pin_part)

    # Combined GAN should be valid
    gan_string = "#{snn_part}:#{pin_part}"
    raise "#{gan_string} should be valid GAN" unless Sashite::Gan.valid?(gan_string)

    # Invalid individual components should make GAN invalid
    invalid_snn = "#{snn_part}Invalid"
    invalid_pin = "#{pin_part}Invalid"

    raise "#{invalid_snn}:#{pin_part} should be invalid (bad SNN)" if Sashite::Gan.valid?("#{invalid_snn}:#{pin_part}")
    raise "#{snn_part}:#{invalid_pin} should be invalid (bad PIN)" if Sashite::Gan.valid?("#{snn_part}:#{invalid_pin}")
  end
end

# Test constants
run_test("Actor class constants are properly defined") do
  actor_class = Sashite::Gan::Actor

  # Test separator constant
  raise "SEPARATOR should be ':'" unless actor_class::SEPARATOR == ":"

  # Test side constants
  raise "FIRST_PLAYER should be :first" unless actor_class::FIRST_PLAYER == :first
  raise "SECOND_PLAYER should be :second" unless actor_class::SECOND_PLAYER == :second

  # Test state constants
  raise "NORMAL_STATE should be :normal" unless actor_class::NORMAL_STATE == :normal
  raise "ENHANCED_STATE should be :enhanced" unless actor_class::ENHANCED_STATE == :enhanced
  raise "DIMINISHED_STATE should be :diminished" unless actor_class::DIMINISHED_STATE == :diminished

  # Test valid arrays
  raise "VALID_SIDES should contain correct values" unless actor_class::VALID_SIDES == [:first, :second]
  raise "VALID_STATES should contain correct values" unless actor_class::VALID_STATES == [:normal, :enhanced, :diminished]
  raise "VALID_TYPES should contain A-Z" unless actor_class::VALID_TYPES.first == :A && actor_class::VALID_TYPES.last == :Z
end

# Test roundtrip parsing
run_test("Roundtrip parsing consistency") do
  test_cases = [
    [:Chess, :K, :first, :normal],
    [:Shogi, :P, :second, :enhanced],
    [:Xiangqi, :G, :first, :diminished],
    [:Chess960, :Q, :second, :normal]
  ]

  test_cases.each do |name, type, side, state|
    # Create actor -> to_s -> parse -> compare
    original = Sashite::Gan::Actor.new(name, type, side, state)
    gan_string = original.to_s
    parsed = Sashite::Gan.parse(gan_string)

    raise "Roundtrip failed: original != parsed" unless original == parsed
    raise "Roundtrip failed: different name" unless original.name == parsed.name
    raise "Roundtrip failed: different type" unless original.type == parsed.type
    raise "Roundtrip failed: different side" unless original.side == parsed.side
    raise "Roundtrip failed: different state" unless original.state == parsed.state

    # Test component extraction roundtrip
    snn_component = original.to_snn
    pin_component = original.to_pin
    reconstructed = "#{snn_component}:#{pin_component}"

    raise "Component roundtrip failed" unless reconstructed == gan_string
  end
end

# Test name capitalization normalization
run_test("Name capitalization normalization") do
  test_cases = [
    # Input cases that should all normalize to the same symbol
    [["CHESS:K", "chess:k"], :Chess],
    [["SHOGI:P", "shogi:p"], :Shogi],
    [["XIANGQI:G", "xiangqi:g"], :Xiangqi],
    [["CHESS960:K", "chess960:k"], :Chess960],
    [["KOTH:Q", "koth:q"], :Koth]
  ]

  test_cases.each do |inputs, expected_name|
    parsed_actors = inputs.map { |input| Sashite::Gan.parse(input) }

    # All should have the same normalized name
    parsed_actors.each do |actor|
      raise "#{inputs.inspect} should normalize to #{expected_name}, got #{actor.name}" unless actor.name == expected_name
    end

    # But different sides
    raise "First input should be first player" unless parsed_actors[0].first_player?
    raise "Second input should be second player" unless parsed_actors[1].second_player?
  end
end

# Test performance with moderate load
run_test("Performance - repeated operations") do
  # Test performance with many repeated calls
  1000.times do
    actor = Sashite::Gan.actor(:Chess, :K, :first, :normal)
    enhanced = actor.enhance
    flipped = actor.flip
    shogi = actor.with_name(:Shogi)

    raise "Performance test failed" unless Sashite::Gan.valid?("CHESS:K")
    raise "Performance test failed" unless enhanced.enhanced?
    raise "Performance test failed" unless flipped.second_player?
    raise "Performance test failed" unless shogi.name == :Shogi
  end
end

# Test comprehensive validation scenarios
run_test("Comprehensive validation scenarios") do
  # Test various valid formats
  valid_formats = [
    "A:A", "Z:Z", "a:a", "z:z",
    "CHESS:K", "chess:k", "SHOGI:P", "shogi:p",
    "CHESS:+K", "chess:+k", "SHOGI:-P", "shogi:-p",
    "CHESS960:K", "chess960:k", "A1B2C3:Z", "a1b2c3:z"
  ]

  valid_formats.each do |gan|
    raise "#{gan} should be valid" unless Sashite::Gan.valid?(gan)
    raise "#{gan} should be parseable" unless Sashite::Gan.parse(gan)
  end

  # Test various invalid formats
  invalid_formats = [
    "", ":", "CHESS", ":K", "CHESS:",
    "Chess:K", "CHESS:k", "chess:K",
    "CHESS:KK", "CHESS::K", "CHESS:::K",
    "123:K", "CHESS:123", "!:K", "CHESS:!",
    "CHESS:++K", "CHESS:--K", "CHESS:+-K"
  ]

  invalid_formats.each do |gan|
    raise "#{gan} should be invalid" if Sashite::Gan.valid?(gan)
  end
end

# Test integration with SNN and PIN libraries
run_test("Integration with SNN and PIN libraries") do
  # Test that GAN actors correctly wrap SNN and PIN objects
  actor = Sashite::Gan.parse("CHESS:+K")

  # Test that internal components work as expected
  raise "Actor should have correct SNN representation" unless actor.to_snn == "CHESS"
  raise "Actor should have correct PIN representation" unless actor.to_pin == "+K"

  # Test that transformations affect both components correctly
  flipped = actor.flip
  raise "Flipped actor should have lowercase SNN" unless flipped.to_snn == "chess"
  raise "Flipped actor should have lowercase PIN" unless flipped.to_pin == "+k"

  # Test that state changes affect only PIN component
  normalized = actor.normalize
  raise "Normalized actor should keep same SNN" unless normalized.to_snn == "CHESS"
  raise "Normalized actor should have modified PIN" unless normalized.to_pin == "K"

  # Test that name changes affect only SNN component
  renamed = actor.with_name(:Shogi)
  raise "Renamed actor should have different SNN" unless renamed.to_snn == "SHOGI"
  raise "Renamed actor should keep same PIN" unless renamed.to_pin == "+K"
end

# Test error propagation from components
run_test("Error propagation from SNN and PIN components") do
  # Test that SNN errors are properly propagated
  begin
    Sashite::Gan.parse("Chess:K")  # Mixed case in SNN
    raise "Should have raised error for mixed case SNN"
  rescue ArgumentError => e
    raise "Should propagate SNN-related error" unless e.message.include?("Case mismatch") || e.message.include?("Invalid")
  end

  # Test that PIN errors are properly propagated
  begin
    Sashite::Gan.parse("CHESS:++K")  # Invalid PIN
    raise "Should have raised error for invalid PIN"
  rescue ArgumentError => e
    raise "Should propagate PIN-related error" unless e.message.include?("Invalid")
  end

  # Test that case mismatch errors are properly raised
  begin
    Sashite::Gan.parse("CHESS:k")  # Case mismatch
    raise "Should have raised error for case mismatch"
  rescue ArgumentError => e
    raise "Should raise case mismatch error" unless e.message.include?("Case mismatch")
  end
end

# Test boundary conditions
run_test("Boundary conditions") do
  # Test minimum valid identifiers
  min_valid = ["A:A", "a:a", "Z:Z", "z:z"]
  min_valid.each do |gan|
    raise "#{gan} should be valid (minimum)" unless Sashite::Gan.valid?(gan)
  end

  # Test maximum reasonable identifiers
  long_identifier = "A" + "B" * 50  # Long but valid identifier
  max_valid = ["#{long_identifier}:A", "#{long_identifier.downcase}:a"]
  max_valid.each do |gan|
    raise "#{gan} should be valid (long identifier)" unless Sashite::Gan.valid?(gan)
  end

  # Test with all piece types
  all_types = ("A".."Z").to_a
  all_types.each do |type|
    gan_upper = "CHESS:#{type}"
    gan_lower = "chess:#{type.downcase}"

    raise "#{gan_upper} should be valid" unless Sashite::Gan.valid?(gan_upper)
    raise "#{gan_lower} should be valid" unless Sashite::Gan.valid?(gan_lower)
  end
end

puts
puts "All GAN tests passed!"
puts
