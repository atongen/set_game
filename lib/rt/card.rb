module Rt
  class Card

    NUM   = %w{ one    two      three  }
    FILL  = %w{ open   shaded   solid  }
    COLOR = %w{ red    blue     yellow }
    SHAPE = %w{ circle triangle square }

    attr_reader :num, :fill, :color, :shape

    def initialize(num, fill, color, shape)
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

    def to_s
      "#{num} #{fill} #{color} #{shape}"
    end

    def to_i
      "#{NUM.index(num)}#{FILL.index(fill)}#{COLOR.index(color)}#{SHAPE.index(shape)}".to_i(3)
    end

    def self.deck
      (0...(3 ** 4)).inject([]) do |deck,i|
        deck << from_i(i)
        deck
      end
    end

    def self.from_i(i)
      v = i.to_s(3).rjust(4, "0").split("").map(&:to_i)
      new(NUM[v[0]], FILL[v[1]], COLOR[v[2]], SHAPE[v[3]])
    end

    def self.from_attr(num, fill, color, shape)
      from_i("#{NUM.index(num)}#{FILL.index(fill)}#{COLOR.index(color)}#{SHAPE.index(shape)}".to_i(3))
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

    def set?(c1, c2, c3)
      c1.is_a?(self.class) && c2.is_a?(self.class) && c3.is_a?(self.class) &&
      [:num, :fill, :color, :shape].all? do |attr|
        ((c1.send(attr) == c2.send(attr) && c2.send(attr) == c3.send(attr)) ||
         (c1.send(attr) != c2.send(attr) && c2.send(attr) != c3.send(attr) && c1.send(attr) != c3.send(attr)))
      end
    end
  end
end
