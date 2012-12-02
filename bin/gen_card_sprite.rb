#!/usr/bin/env ruby

require 'pathname'
require 'RMagick'
include Magick

RT_ROOT = Pathname.new(File.expand_path(File.join('..', '..'), __FILE__))

CARD_WIDTH   = 162
CARD_HEIGHT  = 252
SPRITE_WIDTH  = CARD_WIDTH  * 9
SPRITE_HEIGHT = CARD_HEIGHT * 9

MAP = "RGB"

sprite = Image.new(SPRITE_WIDTH, SPRITE_HEIGHT)

(0...81).each do |i|
  s = i.to_s.rjust(2, '0')
  card_path = RT_ROOT.join('work', 'gen', "#{s}-card.png").to_s
  puts card_path
  card = ImageList.new(card_path)
  pixels = card.
    resize(CARD_WIDTH, CARD_HEIGHT).
    export_pixels_to_str(0, 0, CARD_WIDTH, CARD_HEIGHT, MAP)
  m = i % 9
  n = i / 9
  x = m * CARD_WIDTH
  y = n * CARD_HEIGHT
  sprite.import_pixels(x, y, CARD_WIDTH, CARD_HEIGHT, MAP, pixels)
  card.destroy!
end

sprite.write(RT_ROOT.join('public', 'assets', 'images', 'card_sprite.png'))
