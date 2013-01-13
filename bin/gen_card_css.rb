#!/usr/bin/env ruby

width  = 162
height = 252

(0...81).each do |i|
  x = (i % 9) * width
  y = (i.to_f / 9.0).floor * height
  puts <<EOF
.card-#{i.to_s.rjust(2, '0')} {
  background-position: -#{x}px -#{y}px;
}

EOF
end
