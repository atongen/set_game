#!/usr/bin/env ruby

require 'pathname'
require 'RMagick'
#require 'celluloid'

RT_ROOT = Pathname.new(File.expand_path(File.join('..', '..'), __FILE__))
$:.unshift RT_ROOT.join('lib')
require 'rt/card'

PAD = 20
MAP = "RGB"

SHAPE_WIDTH  = 640
SHAPE_HEIGHT = 320

CARD_WIDTH  = 720
CARD_HEIGHT = 1120

RED    = [1.0, 0.0, 0.0, '#FFFFFF']
BLUE   = [0.0, 0.0, 1.0, '#FFFFFF']
YELLOW = [1.0, 1.0, 0.0, '#FFFFFF']
GREEN  = [0.0, 1.0, 0.0, '#FFFFFF']

$assets = %w{ oval diamond bowtie shaded solid }.inject({}) do |assets, asset|
  assets[asset] = Magick::ImageList.new(RT_ROOT.join('work', 'assets', "#{asset}.png").to_s)[0]
  assets
end

class CardBuilder
  include Magick
  #include Celluloid

  def build(card)
    i = card.i.to_s.rjust(2, '0')
    puts "#{i} #{card}"

    shape_img_list = ImageList.new
    case card.fill
    when 'open'
      # do nothing
    when 'shaded'
      shape_img_list << $assets['shaded']
    when 'solid'
      shape_img_list << $assets['solid']
    end

    case card.shape
    when 'oval'
      shape_img_list << $assets['oval']
    when 'diamond'
      shape_img_list << $assets['diamond']
    when 'bowtie'
      shape_img_list << $assets['bowtie']
    end

    shape_img = shape_img_list.flatten_images
    shape_img_pixels = shape_img.export_pixels_to_str(0, 0, SHAPE_WIDTH, SHAPE_HEIGHT, MAP)
    card_img = Image.new(CARD_WIDTH, CARD_HEIGHT)

    case card.num
    when 'one'
      card_img.import_pixels(PAD*2, PAD*4+SHAPE_HEIGHT, SHAPE_WIDTH, SHAPE_HEIGHT, MAP, shape_img_pixels)
    when 'two'
      card_img.import_pixels(PAD*2, CARD_HEIGHT/2-PAD*2-SHAPE_HEIGHT, SHAPE_WIDTH, SHAPE_HEIGHT, MAP, shape_img_pixels)
      card_img.import_pixels(PAD*2, CARD_HEIGHT/2+PAD,                SHAPE_WIDTH, SHAPE_HEIGHT, MAP, shape_img_pixels)
    when 'three'
      card_img.import_pixels(PAD*2, PAD*2,                SHAPE_WIDTH, SHAPE_HEIGHT, MAP, shape_img_pixels)
      card_img.import_pixels(PAD*2, PAD*4+SHAPE_HEIGHT,   SHAPE_WIDTH, SHAPE_HEIGHT, MAP, shape_img_pixels)
      card_img.import_pixels(PAD*2, PAD*6+SHAPE_HEIGHT*2, SHAPE_WIDTH, SHAPE_HEIGHT, MAP, shape_img_pixels)
    end

    card_img_list = ImageList.new
    card_img_list << card_img

    # set the color
    case card.color
    when 'red'
      card_img_list = card_img_list.colorize(*RED)
    when 'blue'
      card_img_list = card_img_list.colorize(*BLUE)
    when 'yellow'
      card_img_list = card_img_list.colorize(*YELLOW)
    when 'green'
      card_img_list = card_img_list.colorize(*GREEN)
    end

    card_img_list.write(RT_ROOT.join('work', 'gen', "#{i}-card.png").to_s)
    card_img_list.destroy!
    true
  end
end

# Attempt to build cards in parallel - revisit this
#pool = CardBuilder.pool
#futures = Rt::Card::DECK.map do |card|
#  pool.future.build(card)
#end

#futures.map(&:value)

cb = CardBuilder.new
Rt::Card::DECK.each do |card|
  cb.build(card)
end
