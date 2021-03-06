# encoding: utf-8

# A simple Password generator. Central parts are based on a DZone snippet and its comments:
# https://web.archive.org/web/20090204082442/http://snippets.dzone.com/posts/show/2137
class Password
  module CharacterSets
    SAFE_CHARS  = ("A".."Z").to_a | ("a".."z").to_a | ("0".."9").to_a | "-_.,;+!*()[]{}|~^<>\"'$=".split(//)
    URL_UNSAFE  = "#%/:@&?".split(//)
    LOOKALIKE   = "Ss5Bb8|Iio01lO".split(//)

    ALL_CHARS   = SAFE_CHARS | URL_UNSAFE
    URL_SAFE    = SAFE_CHARS
    VISUAL_SAFE = SAFE_CHARS - LOOKALIKE

    CONSONANTS  = %w( b c d f g h j k l m n p r s t v w x z)
    VISUAL_SAFE_CONSONANTS = CONSONANTS & VISUAL_SAFE
    VOWELS      = %w(a     e     i         o       u     y)
    VISUAL_SAFE_VOWELS = VOWELS & VISUAL_SAFE
    COMPOUND    = CONSONANTS | %w(ch cr fr nd ng nk nt ph pr qu rd sch sh sl sp st th tr)
  end


  # default length range value for new password generator instances
  DEFAULT_LENGTH = 8..12

  # the possible length values
  attr_reader :length

  # Creates a new password generator. The length +len+ might be an
  # +Integer+, an +Array+ or a +Range+.
  def initialize(len = DEFAULT_LENGTH)
    coerce_length! len
  end

  class << self
    # Short-hand for +#new.pronouncable+.
    def pronounceable(len = DEFAULT_LENGTH, visual_safe: false)
      new(len).pronounceable(visual_safe: visual_safe)
    end

    # Short-hand for +#new.random+.
    def random(len = DEFAULT_LENGTH)
      new(len).random
    end

    # Short-hand for +#new.urlsafe+.
    def urlsafe(len = DEFAULT_LENGTH)
      new(len).urlsafe
    end

    def visual_safe(len = DEFAULT_LENGTH)
      new(len).visual_safe
    end
  end

  # Generates a pronounceable password.
  def pronounceable(visual_safe:)
    set = rand > 0.5

    consonants = if visual_safe
                   CharacterSets::VISUAL_SAFE_CONSONANTS
                 else
                   CharacterSets::CONSONANTS
                 end

    vowels = if visual_safe
               CharacterSets::VISUAL_SAFE_VOWELS
             else
               CharacterSets::VOWELS
             end

    build_password {
      set = !set
      set ? consonants.sample : vowels.sample
    }
  end

  # Unlike #pronounceable, this does not ensure the pronounceability and
  # will include some special characters, but will exclude "unfriendly"
  # characters (like +0+, +O+).
  def random
    build_password { CharacterSets::ALL_CHARS.sample }
  end

  # Generates a passwort suitable for usage in HTTP(S) URLs, i.e. the
  # following characters are excluded: +:@/+.
  def urlsafe
    build_password { CharacterSets::URL_SAFE.sample }
  end

  def visual_safe
    build_password { CharacterSets::VISUAL_SAFE.sample }
  end

private

  def build_password
    size, pw = length.sample, ''
    while pw.size <= size
      pw << yield
    end
    pw
  end

  def coerce_length!(len)
    length = case len
      when NilClass then DEFAULT_LENGTH.to_a
      when Integer  then (len-1 .. len+1).to_a
      when Range    then len.to_a
      when Array    then len
      else raise ArgumentException, "Length is neither an Integer nor a Range (got #{len.class})."
    end.select{|i| i.is_a?(Integer) && i > 0 }.sort.uniq

    raise TypeError, "Cannot coerce #{len} (#{len.class}) into Password length" if length.empty?

    @length = length
  end

end
