#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/qpi/parser"
require_relative "../../../lib/sashite/qpi/identifier"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "=== Parser Tests ==="
puts

# ============================================================================
# VALID INPUTS - SIMPLE QPI
# ============================================================================

puts "Valid inputs - simple QPI:"

run_test("parses uppercase QPI 'C:K'") do
  result = Sashite::Qpi::Parser.parse("C:K")
  raise "wrong SIN style" unless result[:sin].style == :C
  raise "wrong SIN side" unless result[:sin].side == :first
  raise "wrong PIN type" unless result[:pin].type == :K
  raise "wrong PIN side" unless result[:pin].side == :first
  raise "wrong PIN state" unless result[:pin].state == :normal
  raise "wrong PIN terminal" unless result[:pin].terminal? == false
end

run_test("parses lowercase QPI 'c:k'") do
  result = Sashite::Qpi::Parser.parse("c:k")
  raise "wrong SIN style" unless result[:sin].style == :C
  raise "wrong SIN side" unless result[:sin].side == :second
  raise "wrong PIN type" unless result[:pin].type == :K
  raise "wrong PIN side" unless result[:pin].side == :second
end

run_test("parses mixed case QPI 'C:k' (derived)") do
  result = Sashite::Qpi::Parser.parse("C:k")
  raise "wrong SIN side" unless result[:sin].side == :first
  raise "wrong PIN side" unless result[:pin].side == :second
end

run_test("parses mixed case QPI 'c:K' (derived)") do
  result = Sashite::Qpi::Parser.parse("c:K")
  raise "wrong SIN side" unless result[:sin].side == :second
  raise "wrong PIN side" unless result[:pin].side == :first
end

# ============================================================================
# VALID INPUTS - WITH STATE MODIFIERS
# ============================================================================

puts
puts "Valid inputs - state modifiers:"

run_test("parses enhanced QPI 'S:+R'") do
  result = Sashite::Qpi::Parser.parse("S:+R")
  raise "wrong SIN style" unless result[:sin].style == :S
  raise "wrong PIN type" unless result[:pin].type == :R
  raise "wrong PIN state" unless result[:pin].state == :enhanced
end

run_test("parses diminished QPI 'X:-p'") do
  result = Sashite::Qpi::Parser.parse("X:-p")
  raise "wrong SIN style" unless result[:sin].style == :X
  raise "wrong PIN type" unless result[:pin].type == :P
  raise "wrong PIN side" unless result[:pin].side == :second
  raise "wrong PIN state" unless result[:pin].state == :diminished
end

# ============================================================================
# VALID INPUTS - WITH TERMINAL MARKER
# ============================================================================

puts
puts "Valid inputs - terminal marker:"

run_test("parses terminal QPI 'C:K^'") do
  result = Sashite::Qpi::Parser.parse("C:K^")
  raise "wrong PIN type" unless result[:pin].type == :K
  raise "wrong PIN terminal" unless result[:pin].terminal? == true
end

run_test("parses terminal lowercase QPI 's:k^'") do
  result = Sashite::Qpi::Parser.parse("s:k^")
  raise "wrong SIN side" unless result[:sin].side == :second
  raise "wrong PIN terminal" unless result[:pin].terminal? == true
end

# ============================================================================
# VALID INPUTS - COMBINED
# ============================================================================

puts
puts "Valid inputs - combined modifiers:"

run_test("parses enhanced terminal QPI 'C:+K^'") do
  result = Sashite::Qpi::Parser.parse("C:+K^")
  raise "wrong PIN state" unless result[:pin].state == :enhanced
  raise "wrong PIN terminal" unless result[:pin].terminal? == true
end

run_test("parses diminished terminal QPI 's:-r^'") do
  result = Sashite::Qpi::Parser.parse("s:-r^")
  raise "wrong SIN side" unless result[:sin].side == :second
  raise "wrong PIN state" unless result[:pin].state == :diminished
  raise "wrong PIN terminal" unless result[:pin].terminal? == true
end

# ============================================================================
# VALID INPUTS - VARIOUS STYLES
# ============================================================================

puts
puts "Valid inputs - various styles:"

run_test("parses all uppercase SIN letters") do
  ("A".."Z").each do |letter|
    result = Sashite::Qpi::Parser.parse("#{letter}:K")
    raise "wrong style for #{letter}" unless result[:sin].style == letter.to_sym
  end
end

run_test("parses all lowercase SIN letters") do
  ("a".."z").each do |letter|
    result = Sashite::Qpi::Parser.parse("#{letter}:k")
    raise "wrong style for #{letter}" unless result[:sin].style == letter.upcase.to_sym
    raise "wrong side for #{letter}" unless result[:sin].side == :second
  end
end

# ============================================================================
# VALID? METHOD
# ============================================================================

puts
puts "valid? method:"

run_test("returns true for valid simple QPI") do
  raise "should be valid" unless Sashite::Qpi::Parser.valid?("C:K")
  raise "should be valid" unless Sashite::Qpi::Parser.valid?("c:k")
end

run_test("returns true for valid QPI with modifiers") do
  raise "should be valid" unless Sashite::Qpi::Parser.valid?("S:+R")
  raise "should be valid" unless Sashite::Qpi::Parser.valid?("x:-p")
  raise "should be valid" unless Sashite::Qpi::Parser.valid?("C:K^")
  raise "should be valid" unless Sashite::Qpi::Parser.valid?("S:+R^")
end

run_test("returns true for derived QPI (mixed case)") do
  raise "should be valid" unless Sashite::Qpi::Parser.valid?("C:k")
  raise "should be valid" unless Sashite::Qpi::Parser.valid?("c:K")
end

run_test("returns false for invalid inputs") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("")
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("CK")
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("C:")
  raise "should be invalid" if Sashite::Qpi::Parser.valid?(":K")
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("invalid")
  raise "should be invalid" if Sashite::Qpi::Parser.valid?(nil)
end

# ============================================================================
# ERROR CASES - EMPTY INPUT
# ============================================================================

puts
puts "Error cases - empty input:"

run_test("raises on empty string") do
  Sashite::Qpi::Parser.parse("")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Qpi::Errors::Argument::Messages::EMPTY_INPUT
end

# ============================================================================
# ERROR CASES - MISSING SEPARATOR
# ============================================================================

puts
puts "Error cases - missing separator:"

run_test("raises on missing colon") do
  Sashite::Qpi::Parser.parse("CK")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Qpi::Errors::Argument::Messages::MISSING_SEPARATOR
end

run_test("raises on single letter") do
  Sashite::Qpi::Parser.parse("C")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Qpi::Errors::Argument::Messages::MISSING_SEPARATOR
end

# ============================================================================
# ERROR CASES - MISSING COMPONENTS
# ============================================================================

puts
puts "Error cases - missing components:"

run_test("raises on missing SIN") do
  Sashite::Qpi::Parser.parse(":K")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Qpi::Errors::Argument::Messages::MISSING_SIN
end

run_test("raises on missing PIN") do
  Sashite::Qpi::Parser.parse("C:")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Qpi::Errors::Argument::Messages::MISSING_PIN
end

run_test("raises on colon only") do
  Sashite::Qpi::Parser.parse(":")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Qpi::Errors::Argument::Messages::MISSING_SIN
end

# ============================================================================
# ERROR CASES - INVALID COMPONENTS
# ============================================================================

puts
puts "Error cases - invalid components:"

run_test("raises on invalid SIN (too long)") do
  Sashite::Qpi::Parser.parse("CC:K")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message prefix" unless e.message.start_with?(Sashite::Qpi::Errors::Argument::Messages::INVALID_SIN)
end

run_test("raises on invalid SIN (digit)") do
  Sashite::Qpi::Parser.parse("1:K")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message prefix" unless e.message.start_with?(Sashite::Qpi::Errors::Argument::Messages::INVALID_SIN)
end

run_test("raises on invalid PIN (too long)") do
  Sashite::Qpi::Parser.parse("C:KQR")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message prefix" unless e.message.start_with?(Sashite::Qpi::Errors::Argument::Messages::INVALID_PIN)
end

run_test("raises on invalid PIN (no letter)") do
  Sashite::Qpi::Parser.parse("C:+")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message prefix" unless e.message.start_with?(Sashite::Qpi::Errors::Argument::Messages::INVALID_PIN)
end

# ============================================================================
# SECURITY TESTS - NULL BYTE INJECTION
# ============================================================================

puts
puts "Security - null byte injection:"

run_test("rejects null byte in SIN") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("C\x00:K")
end

run_test("rejects null byte in PIN") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("C:K\x00")
end

run_test("rejects null byte in separator area") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("C\x00:K")
end

# ============================================================================
# SECURITY TESTS - CONTROL CHARACTERS
# ============================================================================

puts
puts "Security - control characters:"

run_test("rejects newline") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("C:K\n")
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("C\n:K")
end

run_test("rejects carriage return") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("C:K\r")
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("\r\nC:K")
end

run_test("rejects tab") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("C:K\t")
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("\tC:K")
end

# ============================================================================
# SECURITY TESTS - UNICODE LOOKALIKES
# ============================================================================

puts
puts "Security - Unicode lookalikes:"

run_test("rejects Cyrillic lookalikes in SIN") do
  # Cyrillic 'С' (U+0421) looks like Latin 'C'
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("\xD0\xA1:K")
end

run_test("rejects Cyrillic lookalikes in PIN") do
  # Cyrillic 'К' (U+041A) looks like Latin 'K'
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("C:\xD0\x9A")
end

run_test("rejects full-width characters") do
  # Full-width 'C' (U+FF23)
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("\xEF\xBC\xA3:K")
end

# ============================================================================
# SECURITY TESTS - MULTIPLE COLONS
# ============================================================================

puts
puts "Security - multiple colons:"

run_test("handles multiple colons (takes first split)") do
  # "C:K:X" should split as SIN="C", PIN="K:X" which is invalid PIN
  raise "should be invalid" if Sashite::Qpi::Parser.valid?("C:K:X")
end

# ============================================================================
# SECURITY TESTS - NON-STRING INPUT
# ============================================================================

puts
puts "Security - non-string input:"

run_test("rejects nil") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?(nil)
end

run_test("rejects integer") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?(123)
end

run_test("rejects array") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?(["C:K"])
end

run_test("rejects hash") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?({ sin: "C", pin: "K" })
end

run_test("rejects symbol") do
  raise "should be invalid" if Sashite::Qpi::Parser.valid?(:"C:K")
end

# ============================================================================
# ROUND-TRIP TESTS
# ============================================================================

puts
puts "Round-trip tests:"

run_test("round-trip simple QPI") do
  %w[C:K c:k S:R s:r].each do |qpi|
    result = Sashite::Qpi::Parser.parse(qpi)
    identifier = Sashite::Qpi::Identifier.new(result[:sin], result[:pin])
    raise "round-trip failed for #{qpi}" unless identifier.to_s == qpi
  end
end

run_test("round-trip derived QPI") do
  %w[C:k c:K S:r s:R].each do |qpi|
    result = Sashite::Qpi::Parser.parse(qpi)
    identifier = Sashite::Qpi::Identifier.new(result[:sin], result[:pin])
    raise "round-trip failed for #{qpi}" unless identifier.to_s == qpi
  end
end

run_test("round-trip with state modifiers") do
  %w[C:+K c:+k S:-R s:-r C:+k c:-K].each do |qpi|
    result = Sashite::Qpi::Parser.parse(qpi)
    identifier = Sashite::Qpi::Identifier.new(result[:sin], result[:pin])
    raise "round-trip failed for #{qpi}" unless identifier.to_s == qpi
  end
end

run_test("round-trip with terminal marker") do
  %w[C:K^ c:k^ S:R^ s:r^ C:k^ c:K^].each do |qpi|
    result = Sashite::Qpi::Parser.parse(qpi)
    identifier = Sashite::Qpi::Identifier.new(result[:sin], result[:pin])
    raise "round-trip failed for #{qpi}" unless identifier.to_s == qpi
  end
end

run_test("round-trip combined") do
  %w[C:+K^ c:-k^ S:+R^ s:-r^ C:+k^ c:-K^].each do |qpi|
    result = Sashite::Qpi::Parser.parse(qpi)
    identifier = Sashite::Qpi::Identifier.new(result[:sin], result[:pin])
    raise "round-trip failed for #{qpi}" unless identifier.to_s == qpi
  end
end

puts
puts "All Parser tests passed!"
puts
