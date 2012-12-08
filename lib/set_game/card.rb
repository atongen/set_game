module SetGame
  class Card

    attr_reader :i, :num, :fill, :color, :shape

    NUM   = %w{ one    two      three  }
    FILL  = %w{ open   shaded   solid  }
    COLOR = %w{ red    blue     green }
    SHAPE = %w{ oval   diamond  bowtie }

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

    def self.from_i(i)
      v = i.to_s(3).rjust(4, "0").split("").map(&:to_i)
      new(i, NUM[v[0]], FILL[v[1]], COLOR[v[2]], SHAPE[v[3]])
    end

    private_class_method :new, :from_i

    DECK = (0...81).map { |i| from_i(i) }

    def self.each
      DECK.each { yield }
    end

    def <=>(other)
      i <=> other.i
    end

    include Enumerable

    def self.from_attr(num, fill, color, shape)
      DECK["#{NUM.index(num)}#{FILL.index(fill)}#{COLOR.index(color)}#{SHAPE.index(shape)}".to_i(3)]
    end

    def to_s
      "#{num} #{fill} #{color} #{shape}"
    end

    def inspect
      oid = '%x' % (object_id << 1)
      "<#{self.class.name}:0x#{oid} i:#{i} num:#{num} fill:#{fill} color:#{color} shape:#{shape}>"
    end

    def num_i
      NUM.index(num)
    end

    def fill_i
      FILL.index(fill)
    end

    def color_i
      COLOR.index(color)
    end

    def shape_i
      SHAPE.index(shape)
    end

    def complete(other)
      c_num   = num   == other.num   ? num   : (NUM   - [num,   other.num]).first
      c_fill  = fill  == other.fill  ? fill  : (FILL  - [fill,  other.fill]).first
      c_color = color == other.color ? color : (COLOR - [color, other.color]).first
      c_shape = shape == other.shape ? shape : (SHAPE - [shape, other.shape]).first
      self.class.from_attr(c_num, c_fill, c_color, c_shape)
    end

    def ==(other)
      self.equal?(other) ||
        other.is_a?(self.class) &&
        num   == other.num &&
        fill  == other.fill &&
        color == other.color &&
        shape == other.shape
    end

    def self.set_index?(i1, i2, i3)
      set?(*DECK.values_at(i1, i2, i3))
    end

    def self.set?(c1, c2, c3)
      [:num, :fill, :color, :shape].all? do |attr|
        ((c1.send(attr) == c2.send(attr) && c2.send(attr) == c3.send(attr)) ||
         (c1.send(attr) != c2.send(attr) && c2.send(attr) != c3.send(attr) && c1.send(attr) != c3.send(attr)))
      end
    end

    def self.find_sets(*indexes)
      cards = DECK.values_at(*indexes)
      sets = []
      l = cards.length
      if cards.length >= 3
        (0..(l-3)).each do |i|
          (1..(l-2)).each do |j|
            (2..(l-1)).each do |k|
              if set?(cards[i], cards[j], cards[k])
                sets << [cards[i], cards[j], cards[k]]
              end
            end
          end
        end
      end
      sets
    end
  end
end
