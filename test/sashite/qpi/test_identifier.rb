#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/qpi"

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
puts "=== Identifier Tests ==="
puts

# ============================================================================
# CONSTRUCTION
# ============================================================================

puts "Construction:"

run_test("creates identifier from SIN and PIN components") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "wrong SIN" unless qpi.sin == sin
  raise "wrong PIN" unless qpi.pin == pin
end

run_test("creates identifier with enhanced PIN") do
  sin = Sashite::Sin.parse("S")
  pin = Sashite::Pin.parse("+R")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "wrong PIN state" unless qpi.pin.state == :enhanced
end

run_test("creates identifier with terminal PIN") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K^")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "wrong PIN terminal" unless qpi.pin.terminal? == true
end

run_test("creates derived identifier (mixed case)") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "wrong SIN side" unless qpi.sin.side == :first
  raise "wrong PIN side" unless qpi.pin.side == :second
end

# ============================================================================
# CONSTRUCTION VALIDATION
# ============================================================================

puts
puts "Construction validation:"

run_test("raises on nil SIN") do
  pin = Sashite::Pin.parse("K")
  Sashite::Qpi::Identifier.new(nil, pin)
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Qpi::Errors::Argument::Messages::INVALID_SIN
end

run_test("raises on nil PIN") do
  sin = Sashite::Sin.parse("C")
  Sashite::Qpi::Identifier.new(sin, nil)
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Qpi::Errors::Argument::Messages::INVALID_PIN
end

run_test("raises on string SIN") do
  pin = Sashite::Pin.parse("K")
  Sashite::Qpi::Identifier.new("C", pin)
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Qpi::Errors::Argument::Messages::INVALID_SIN
end

run_test("raises on string PIN") do
  sin = Sashite::Sin.parse("C")
  Sashite::Qpi::Identifier.new(sin, "K")
  raise "should have raised"
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Qpi::Errors::Argument::Messages::INVALID_PIN
end

# ============================================================================
# STRING CONVERSION
# ============================================================================

puts
puts "String conversion:"

run_test("to_s returns simple QPI") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "wrong string" unless qpi.to_s == "C:K"
end

run_test("to_s returns lowercase QPI") do
  sin = Sashite::Sin.parse("c")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "wrong string" unless qpi.to_s == "c:k"
end

run_test("to_s returns derived QPI") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "wrong string" unless qpi.to_s == "C:k"
end

run_test("to_s returns QPI with state modifier") do
  sin = Sashite::Sin.parse("S")
  pin = Sashite::Pin.parse("+R")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "wrong string" unless qpi.to_s == "S:+R"
end

run_test("to_s returns QPI with terminal marker") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K^")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "wrong string" unless qpi.to_s == "C:K^"
end

run_test("to_s returns QPI with all modifiers") do
  sin = Sashite::Sin.parse("S")
  pin = Sashite::Pin.parse("+R^")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "wrong string" unless qpi.to_s == "S:+R^"
end

# ============================================================================
# NATIVE/DERIVED QUERIES
# ============================================================================

puts
puts "Native/Derived queries:"

run_test("native? returns true when both uppercase") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "should be native" unless qpi.native? == true
  raise "should not be derived" unless qpi.derived? == false
end

run_test("native? returns true when both lowercase") do
  sin = Sashite::Sin.parse("c")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "should be native" unless qpi.native? == true
  raise "should not be derived" unless qpi.derived? == false
end

run_test("derived? returns true when SIN uppercase, PIN lowercase") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "should not be native" unless qpi.native? == false
  raise "should be derived" unless qpi.derived? == true
end

run_test("derived? returns true when SIN lowercase, PIN uppercase") do
  sin = Sashite::Sin.parse("c")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "should not be native" unless qpi.native? == false
  raise "should be derived" unless qpi.derived? == true
end

# ============================================================================
# NATIVE TRANSFORMATION
# ============================================================================

puts
puts "Native transformation:"

run_test("native returns self when already native (uppercase)") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.native
  raise "should return self" unless result.equal?(qpi)
end

run_test("native returns self when already native (lowercase)") do
  sin = Sashite::Sin.parse("c")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.native
  raise "should return self" unless result.equal?(qpi)
end

run_test("native aligns PIN case to SIN (uppercase)") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.native
  raise "should not return self" if result.equal?(qpi)
  raise "wrong string" unless result.to_s == "C:K"
  raise "should be native" unless result.native? == true
end

run_test("native aligns PIN case to SIN (lowercase)") do
  sin = Sashite::Sin.parse("c")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.native
  raise "should not return self" if result.equal?(qpi)
  raise "wrong string" unless result.to_s == "c:k"
  raise "should be native" unless result.native? == true
end

run_test("native preserves PIN state and terminal") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("+k^")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.native
  raise "wrong string" unless result.to_s == "C:+K^"
  raise "wrong state" unless result.pin.state == :enhanced
  raise "wrong terminal" unless result.pin.terminal? == true
end

# ============================================================================
# DERIVE TRANSFORMATION
# ============================================================================

puts
puts "Derive transformation:"

run_test("derive returns self when already derived (SIN upper, PIN lower)") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.derive
  raise "should return self" unless result.equal?(qpi)
end

run_test("derive returns self when already derived (SIN lower, PIN upper)") do
  sin = Sashite::Sin.parse("c")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.derive
  raise "should return self" unless result.equal?(qpi)
end

run_test("derive makes PIN case opposite to SIN (from uppercase native)") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.derive
  raise "should not return self" if result.equal?(qpi)
  raise "wrong string" unless result.to_s == "C:k"
  raise "should be derived" unless result.derived? == true
end

run_test("derive makes PIN case opposite to SIN (from lowercase native)") do
  sin = Sashite::Sin.parse("c")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.derive
  raise "should not return self" if result.equal?(qpi)
  raise "wrong string" unless result.to_s == "c:K"
  raise "should be derived" unless result.derived? == true
end

run_test("derive preserves PIN state and terminal") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("+K^")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.derive
  raise "wrong string" unless result.to_s == "C:+k^"
  raise "wrong state" unless result.pin.state == :enhanced
  raise "wrong terminal" unless result.pin.terminal? == true
end

# ============================================================================
# WITH_SIN TRANSFORMATION
# ============================================================================

puts
puts "with_sin transformation:"

run_test("with_sin replaces SIN component") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  new_sin = Sashite::Sin.parse("S")
  result = qpi.with_sin(new_sin)
  raise "wrong string" unless result.to_s == "S:K"
  raise "wrong SIN" unless result.sin == new_sin
  raise "PIN should be unchanged" unless result.pin == pin
end

run_test("with_sin can change native to derived") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "should start native" unless qpi.native?
  new_sin = Sashite::Sin.parse("s")
  result = qpi.with_sin(new_sin)
  raise "should become derived" unless result.derived?
  raise "wrong string" unless result.to_s == "s:K"
end

run_test("with_sin preserves PIN fully") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("+K^")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  new_sin = Sashite::Sin.parse("X")
  result = qpi.with_sin(new_sin)
  raise "wrong string" unless result.to_s == "X:+K^"
end

# ============================================================================
# WITH_PIN TRANSFORMATION
# ============================================================================

puts
puts "with_pin transformation:"

run_test("with_pin replaces PIN component") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  new_pin = Sashite::Pin.parse("Q")
  result = qpi.with_pin(new_pin)
  raise "wrong string" unless result.to_s == "C:Q"
  raise "SIN should be unchanged" unless result.sin == sin
  raise "wrong PIN" unless result.pin == new_pin
end

run_test("with_pin can change native to derived") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "should start native" unless qpi.native?
  new_pin = Sashite::Pin.parse("q")
  result = qpi.with_pin(new_pin)
  raise "should become derived" unless result.derived?
  raise "wrong string" unless result.to_s == "C:q"
end

run_test("with_pin can add state modifier") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  new_pin = Sashite::Pin.parse("+K")
  result = qpi.with_pin(new_pin)
  raise "wrong string" unless result.to_s == "C:+K"
end

run_test("with_pin can add terminal marker") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  new_pin = Sashite::Pin.parse("K^")
  result = qpi.with_pin(new_pin)
  raise "wrong string" unless result.to_s == "C:K^"
end

# ============================================================================
# FLIP TRANSFORMATION
# ============================================================================

puts
puts "flip transformation:"

run_test("flip changes PIN side only (SIN unchanged)") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.flip
  raise "wrong string" unless result.to_s == "C:k"
  raise "SIN should be unchanged" unless result.sin.side == :first
  raise "PIN side should be flipped" unless result.pin.side == :second
end

run_test("flip from lowercase PIN to uppercase PIN") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.flip
  raise "wrong string" unless result.to_s == "C:K"
  raise "SIN should be unchanged" unless result.sin.side == :first
  raise "PIN side should be flipped" unless result.pin.side == :first
end

run_test("flip with lowercase SIN changes PIN side only") do
  sin = Sashite::Sin.parse("c")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.flip
  raise "wrong string" unless result.to_s == "c:K"
  raise "SIN should be unchanged" unless result.sin.side == :second
  raise "PIN side should be flipped" unless result.pin.side == :first
end

run_test("flip changes native to derived") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("K")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "should start native" unless qpi.native?
  result = qpi.flip
  raise "should become derived" unless result.derived?
end

run_test("flip changes derived to native") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("k")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  raise "should start derived" unless qpi.derived?
  result = qpi.flip
  raise "should become native" unless result.native?
end

run_test("flip preserves PIN state and terminal") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("+K^")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.flip
  raise "wrong string" unless result.to_s == "C:+k^"
  raise "wrong state" unless result.pin.state == :enhanced
  raise "wrong terminal" unless result.pin.terminal? == true
end

run_test("double flip returns equivalent") do
  sin = Sashite::Sin.parse("C")
  pin = Sashite::Pin.parse("+K^")
  qpi = Sashite::Qpi::Identifier.new(sin, pin)
  result = qpi.flip.flip
  raise "wrong string" unless result.to_s == qpi.to_s
end

# ============================================================================
# EQUALITY
# ============================================================================

puts
puts "Equality:"

run_test("== returns true for equal identifiers") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("C:K")
  raise "should be equal" unless qpi1 == qpi2
end

run_test("== returns false for different SIN") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("S:K")
  raise "should not be equal" if qpi1 == qpi2
end

run_test("== returns false for different PIN") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("C:Q")
  raise "should not be equal" if qpi1 == qpi2
end

run_test("== returns false for different case") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("c:k")
  raise "should not be equal" if qpi1 == qpi2
end

run_test("== returns false for native vs derived") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("C:k")
  raise "should not be equal" if qpi1 == qpi2
end

run_test("== returns false for different state") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("C:+K")
  raise "should not be equal" if qpi1 == qpi2
end

run_test("== returns false for different terminal") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("C:K^")
  raise "should not be equal" if qpi1 == qpi2
end

run_test("== returns false for non-Identifier") do
  qpi = Sashite::Qpi.parse("C:K")
  raise "should not equal string" if qpi == "C:K"
  raise "should not equal nil" if qpi == nil
end

run_test("eql? is aliased to ==") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("C:K")
  raise "eql? should work" unless qpi1.eql?(qpi2)
end

run_test("hash is equal for equal identifiers") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("C:K")
  raise "hash should be equal" unless qpi1.hash == qpi2.hash
end

run_test("hash differs for different identifiers") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("S:Q")
  raise "hash should differ" if qpi1.hash == qpi2.hash
end

run_test("can be used as hash key") do
  qpi1 = Sashite::Qpi.parse("C:K")
  qpi2 = Sashite::Qpi.parse("C:K")
  hash = { qpi1 => "value" }
  raise "should find by equal key" unless hash[qpi2] == "value"
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "Immutability:"

run_test("identifier is frozen") do
  qpi = Sashite::Qpi.parse("C:K")
  raise "should be frozen" unless qpi.frozen?
end

run_test("transformations return new instances") do
  qpi = Sashite::Qpi.parse("C:K")
  raise "flip should return new instance" if qpi.flip.equal?(qpi)
  raise "with_sin should return new instance" if qpi.with_sin(Sashite::Sin.parse("S")).equal?(qpi)
  raise "with_pin should return new instance" if qpi.with_pin(Sashite::Pin.parse("Q")).equal?(qpi)
end

run_test("derive returns new instance when not already derived") do
  qpi = Sashite::Qpi.parse("C:K")
  raise "derive should return new instance" if qpi.derive.equal?(qpi)
end

run_test("native returns new instance when not already native") do
  qpi = Sashite::Qpi.parse("C:k")
  raise "native should return new instance" if qpi.native.equal?(qpi)
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "Inspect:"

run_test("inspect returns readable representation") do
  qpi = Sashite::Qpi.parse("C:K")
  inspect = qpi.inspect
  raise "should include class name" unless inspect.include?("Sashite::Qpi::Identifier")
  raise "should include string representation" unless inspect.include?("C:K")
end

run_test("inspect works with modifiers") do
  qpi = Sashite::Qpi.parse("S:+R^")
  inspect = qpi.inspect
  raise "should include string representation" unless inspect.include?("S:+R^")
end

puts
puts "All Identifier tests passed!"
puts
