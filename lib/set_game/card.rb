module SetGame
  # This class contains an array of all cards
  # and logic for checking and finding sets within groups of cards
  class Card

    attr_reader :i, :num, :fill, :color, :shape

    # Number of identical figures found on the card
    NUM   = %w{ one    two      three  }

    # Fill type of a figure on a card
    FILL  = %w{ open   shaded   solid  }

    # Color of a figure on a card
    COLOR = %w{ red    blue     green }

    # Shape of a figure on a card
    SHAPE = %w{ oval   diamond  bowtie }

    # Card constructor
    #
    # Called internally when generating DECK
    #
    # @private
    def initialize(i, num, fill, color, shape)
      if (0...81).include?(i)
        @i = i
      else
        raise "Invalid i"
      end
      if NUM.include?(num)
        @num = num
      else
        raise "Invalid num: #{num}"
      end
      if FILL.include?(fill)
        @fill = fill
      else
        raise "Invalid fill: #{shade}"
      end
      if COLOR.include?(color)
        @color = color
      else
        raise "Invalid color: #{color}"
      end
      if SHAPE.include?(shape)
        @shape = shape
      else
        raise "Invalid shape: #{shape}"
      end
    end

    # Build a card from i - the index of the card: 0-80
    #
    # @private
    def self.from_i(i)
      v = i.to_s(3).rjust(4, "0").split("").map(&:to_i)
      new(i, NUM[v[0]], FILL[v[1]], COLOR[v[2]], SHAPE[v[3]])
    end

    private_class_method :new, :from_i

    # Array of all cards
    DECK = (0...81).map { |i| from_i(i) }

    # Get a card from the deck by index
    #
    # @param [Integer] i the index of the card 0-80
    # @return [Card]
    def self.get(i)
      DECK[i]
    end

    # Yield each card in the deck
    def self.each
      DECK.each { yield }
    end

    # Compare cards by index
    #
    # @param [Card] other card to compare
    # @return -1,0,1 comparable
    def <=>(other)
      if other.is_a?(Card)
        i <=> other.i
      else
        super
      end
    end

    include Enumerable

    # Find the card in the deck from the string representation of it's attributes
    #
    # @param [String] num
    # @param [String] fill
    # @param [String] color
    # @param [String] shape
    # @return [Card]
    def self.from_attr(num, fill, color, shape)
      DECK["#{NUM.index(num)}#{FILL.index(fill)}#{COLOR.index(color)}#{SHAPE.index(shape)}".to_i(3)]
    end

    # Get the card from the string representation
    #
    # @param [String] str
    # @return [Card]
    def self.from_s(str)
      from_attr(*str.split(/\s+/))
    end

    def to_s
      "#{num} #{fill} #{color} #{shape}"
    end

    def inspect
      oid = '%x' % (object_id << 1)
      "<#{self.class.name}:0x#{oid} i:#{i} num:#{num} fill:#{fill} color:#{color} shape:#{shape}>"
    end

    def ==(other)
      self.equal?(other) ||
        other.is_a?(self.class) &&
        num   == other.num &&
        fill  == other.fill &&
        color == other.color &&
        shape == other.shape
    end

    def complete(other)
      self.class.complete(self, other)
    end

    # Given two cards, return the third card that will produce a set
    #
    # @param [Card] c1 the first card
    # @param [Card] c2 the second card
    # @return [Card] the card to produce a set with c1 and c2
    def self.complete(c1, c2)
      c_num   = c1.num   == c2.num   ? c1.num   : (NUM   - [c1.num,   c2.num]).first
      c_fill  = c1.fill  == c2.fill  ? c1.fill  : (FILL  - [c1.fill,  c2.fill]).first
      c_color = c1.color == c2.color ? c1.color : (COLOR - [c1.color, c2.color]).first
      c_shape = c1.shape == c2.shape ? c1.shape : (SHAPE - [c1.shape, c2.shape]).first
      self.from_attr(c_num, c_fill, c_color, c_shape)
    end

    # Do these three cards produce a set?
    #
    # @param [Card] c1 the first card
    # @param [Card] c2 the second card
    # @param [Card] c3 the third card
    # @return [Boolean]
    def self.set?(c1, c2, c3)
      [:num, :fill, :color, :shape].all? do |attr|
        ((c1.send(attr) == c2.send(attr) && c2.send(attr) == c3.send(attr)) ||
         (c1.send(attr) != c2.send(attr) && c2.send(attr) != c3.send(attr) && c1.send(attr) != c3.send(attr)))
      end
    end

    # Do these three card indexes produce a set?
    #
    # @param [Integer] i1 the index of the first card
    # @param [Integer] i2 the index of the second card
    # @param [Integer] i3 the index of the third card
    # @return [Boolean]
    def self.set_index?(i1, i2, i3)
      set?(*DECK.values_at(i1, i2, i3))
    end

    # Finds sets within the array of indexes of cards passed in
    #
    # @param [Array] indexes of the cards to find sets within
    # @return [Array] of arrays of found set indexes
    def self.find_sets(indexes)
      idx = indexes.compact
      l = idx.length
      sets = []
      return sets if l < 3

      (0..(l-3)).each do |i|
        ((i+1)..(l-2)).each do |j|
          ((j+1)..(l-1)).each do |k|
            if set?(DECK[idx[i]], DECK[idx[j]], DECK[idx[k]])
              sets << [idx[i], idx[j], idx[k]]
            end
          end
        end
      end
      sets
    end

    # Counts sets within the array of indexes of cards passed in
    #
    # @param [Array] indexes of the cards to find sets within
    # @return [Integer] number of found sets
    def self.count_sets(indexes)
      idx = indexes.compact
      l = idx.length
      return 0 if l < 3

      sets = 0
      (0..(l-3)).each do |i|
        ((i+1)..(l-2)).each do |j|
          ((j+1)..(l-1)).each do |k|
            if set?(DECK[idx[i]], DECK[idx[j]], DECK[idx[k]])
              sets += 1
            end
          end
        end
      end
      sets
    end

    # Searches for a set within the indexes provided as an array
    # Returns true as soon as one is found
    #
    # @param [Array] indexes of the cards to search within
    # @return [Boolean] set exists in indexes
    def self.set_exists?(indexes)
      idx = indexes.compact
      l = idx.length
      return false if l < 3

      (0..(l-3)).each do |i|
        ((i+1)..(l-2)).each do |j|
          ((j+1)..(l-1)).each do |k|
            if set?(DECK[idx[i]], DECK[idx[j]], DECK[idx[k]])
              return true
            end
          end
        end
      end
      false
    end

  end
end
