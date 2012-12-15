require 'spec_helper'

describe SetGame::Card do
  it 'has 81 of them' do
    SetGame::Card::DECK.length.must_equal 81
  end

  it 'must have a string representation' do
    SetGame::Card.get(0).to_s.must_equal "one open red oval"
  end

  it 'must be able to complete sets' do
    r1 = rand(81)
    begin
      r2 = rand(81)
    end until r2 != r1
    c1 = SetGame::Card.get(r1)
    c2 = SetGame::Card.get(r2)
    c3 = SetGame::Card.complete(c1, c2)
    SetGame::Card.set?(c1, c2, c3).must_equal(true)
  end

  it 'must be able to find sets' do
    SetGame::Card.find_sets([0,1,2,3]).must_equal([[0,1,2]])
    SetGame::Card.find_sets([0,1,3,4]).must_equal([])

    card_strs = [
      "one open red oval",
      "two shaded blue diamond",
      "three solid green bowtie"
    ]
    card_idxs = card_strs.map { |s| SetGame::Card.from_s(s).i }
    result = SetGame::Card.find_sets(card_idxs)
    result.length.must_equal(1)
    result.first.map { |i| SetGame::Card.get(i).to_s }.must_equal(card_strs)
  end

  it 'must be able to count sets' do
    SetGame::Card.count_sets([0, 1, 2]).must_equal(1)
    SetGame::Card.count_sets([0, 1, 3]).must_equal(0)
    SetGame::Card.set_exists?([0, 1, 2]).must_equal(true)
    SetGame::Card.set_exists?([0, 1, 3]).must_equal(false)
  end

end
