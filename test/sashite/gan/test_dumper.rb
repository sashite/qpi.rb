# frozen_string_literal: true

require_relative "../../../lib/sashite/gan/dumper"

puts "Testing Sashite::Gan::Dumper..."

# Test 1: Basic functionality with a chess king
result = Sashite::Gan::Dumper.dump(game_id: "CHESS", letter: "K")
raise "Expected 'CHESS:K', got '#{result}'" unless result == "CHESS:K"

# Test 2: Basic functionality with a black chess king (lowercase)
result = Sashite::Gan::Dumper.dump(game_id: "chess", letter: "k")
raise "Expected 'chess:k', got '#{result}'" unless result == "chess:k"

# Test 3: With prefix (promoted shogi pawn)
# Note: This test will pass because '+P' is considered uppercase because 'P' is uppercase
result = Sashite::Gan::Dumper.dump(game_id: "SHOGI", letter: "P", prefix: "+")
raise "Expected 'SHOGI:+P', got '#{result}'" unless result == "SHOGI:+P"

# Test 4: With suffix (chess king with castling rights)
# Note: This test will pass because 'K'' is considered uppercase because 'K' is uppercase
result = Sashite::Gan::Dumper.dump(game_id: "CHESS", letter: "K", suffix: "'")
raise "Expected 'CHESS:K'', got '#{result}'" unless result == "CHESS:K'"

# Test 5: With both prefix and suffix
# Note: This test will pass because '+R'' is considered uppercase because 'R' is uppercase
result = Sashite::Gan::Dumper.dump(game_id: "SHOGI", letter: "R", prefix: "+", suffix: "'")
raise "Expected 'SHOGI:+R'', got '#{result}'" unless result == "SHOGI:+R'"

# Test 6: String conversion for non-string game_id
result = Sashite::Gan::Dumper.dump(game_id: :CHESS, letter: "K")
raise "Expected 'CHESS:K', got '#{result}'" unless result == "CHESS:K"

# Test 7: Error handling - invalid game_id (contains numbers)
begin
  Sashite::Gan::Dumper.dump(game_id: "CHESS123", letter: "K")
  raise "Expected ArgumentError for invalid game_id, but no error was raised"
rescue ArgumentError => e
  expected_message = "Game ID must be a non-empty string containing only ASCII letters and must be either all uppercase or all lowercase: CHESS123"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 8: Error handling - invalid game_id (contains special characters)
begin
  Sashite::Gan::Dumper.dump(game_id: "CHESS-VARIANT", letter: "K")
  raise "Expected ArgumentError for invalid game_id, but no error was raised"
rescue ArgumentError => e
  expected_message = "Game ID must be a non-empty string containing only ASCII letters and must be either all uppercase or all lowercase: CHESS-VARIANT"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 9: Error handling - casing mismatch (uppercase game_id with lowercase letter)
begin
  Sashite::Gan::Dumper.dump(game_id: "CHESS", letter: "k")
  raise "Expected ArgumentError for casing mismatch, but no error was raised"
rescue ArgumentError => e
  expected_message = "Game ID casing (CHESS) must match piece letter casing (k)"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 10: Error handling - casing mismatch (lowercase game_id with uppercase letter)
begin
  Sashite::Gan::Dumper.dump(game_id: "chess", letter: "K")
  raise "Expected ArgumentError for casing mismatch, but no error was raised"
rescue ArgumentError => e
  expected_message = "Game ID casing (chess) must match piece letter casing (K)"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 11: Test with single-letter game_id
result = Sashite::Gan::Dumper.dump(game_id: "X", letter: "K")
raise "Expected 'X:K', got '#{result}'" unless result == "X:K"

# Test 12: Test with very long game_id
long_game_id = "VERYLONGGAMEID"
result = Sashite::Gan::Dumper.dump(game_id: long_game_id, letter: "K")
raise "Expected '#{long_game_id}:K', got '#{result}'" unless result == "#{long_game_id}:K"

# Test 13: Empty string game_id (should raise error)
begin
  Sashite::Gan::Dumper.dump(game_id: "", letter: "K")
  raise "Expected ArgumentError for empty game_id, but no error was raised"
rescue ArgumentError => e
  expected_message = "Game ID must be a non-empty string containing only ASCII letters and must be either all uppercase or all lowercase: "
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 14: Error handling - mixed case game_id (should be invalid according to GAN spec)
begin
  Sashite::Gan::Dumper.dump(game_id: "ChEsS", letter: "C")
  raise "Expected ArgumentError for mixed case game_id, but no error was raised"
rescue ArgumentError => e
  expected_message = "Game ID must be a non-empty string containing only ASCII letters and must be either all uppercase or all lowercase: ChEsS"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 15: Test behavior with lowercase letter and uppercase prefix character
begin
  Sashite::Gan::Dumper.dump(game_id: "chess", letter: "p", prefix: "+")
  # This should pass with your current implementation
  # Note: With a more strict implementation that extracts the letter, this would fail
  # since '+p' contains a lowercase letter 'p', which matches 'chess'
rescue ArgumentError => e
  # This error should not occur with your current implementation
  raise "Unexpected error: #{e.message}"
end

# Test 16: Test behavior with uppercase letter and uppercase prefix character
begin
  Sashite::Gan::Dumper.dump(game_id: "CHESS", letter: "P", prefix: "+")
rescue ArgumentError => e
  # This error should not occur with your current implementation
  raise "Unexpected error: #{e.message}"
end

puts "All Sashite::Gan::Dumper tests passed!"
