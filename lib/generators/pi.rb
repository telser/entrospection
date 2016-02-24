#!/usr/bin/env ruby

# This generates a pseudo-random sequence, the digits of pi in hex
# Digits are calculated using the method as described at
# https://en.wikipedia.org/wiki/Bailey-Borwein-Plouffe_formula


require_relative '../generator.rb'

class PiGenerator < Generator

  def initialize(*args)
    super(*args)
    @i = -1
  end

  def self.summary
    "Pseudo-random number generator using calculated digits of pi"
  end

  def self.description
    desc = <<-DESC_END
      This generator uses the Bailey-Borwein-Plouffe formula of calculating
      the nth digit of pi without needing to calculate previous digits.
      Digits of pi, in hexidecimal, are used as pseudo random numbers.
    DESC_END
    desc.gsub(/\s+/, " ").strip
  end


  # Perform one of the summations in the bbp formula
  def S(j,n)
    left = 0.0
    k = 0
    right = 0.0

    # Perform the first, 'left', sum of the bbp formula
    while k <= n
      r = (8.0 * k) + j
      left = (left + (((16**n).modulo(r)) / r)).modulo(1.0)
      k +=1
    end

    # Perform the 'right' sum of the bbp formula
    k = n+1
    stable = false
    while !stable
      tempRight = right + ((16 ** (n - k)) / ((8 * k) +j))
      if right == tempRight
        stable = true
      end
      right = tempRight
      k += 1
    end

    left + right

  end

  # Overflows ruby floating point at, and above, 257
  def bbp(n)
    n -=1
    # Perform the summation to calculate the n-th digit of pi
    x = ( 4 * S(1,n) - 2 * S(4,n) - S(5,n) - S(6,n)).modulo(1.0)
    # This will give back 7 hex digits of pi, even though we only care about the first
    z = (x * 16**7)
    "%07x" % z
  end

  def next_chunk
    @i +=1
    x = bbp(@i).to_s.chars[0]
    [ x ].pack('A')
  end

end

PiGenerator.run if __FILE__ == $0
