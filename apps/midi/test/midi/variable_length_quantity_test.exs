defmodule MIDI.VariableLengthQuantityTest do
  use ExUnit.Case
  alias MIDI.VariableLengthQuantity

  describe "parse" do
    test "empty binary" do
      {n, ""} = VariableLengthQuantity.parse(<<0x00>>)
      assert n === 0x00
    end

    test "single octet, non-zero" do
      {n, ""} = VariableLengthQuantity.parse(<<0x7F>>)
      assert n === 0x0000007F
    end

    test "multile octets" do
      {n, ""} = VariableLengthQuantity.parse(<<0xFF, 0x7F>>)
      assert n === 0x00003FFF
    end

    test "big number" do
      {n, ""} = VariableLengthQuantity.parse(<<0xFF, 0xFF, 0xFF, 0x7F>>)
      assert n === 0x0FFFFFFF
    end
  end

  describe "encode" do
    test "empty binary" do
      n = VariableLengthQuantity.encode(0x00)
      assert n === <<0x00>>
    end

    test "single octet, non-zero" do
      n = VariableLengthQuantity.encode(0x00000040)
      assert n === <<0x40>>
    end

    test "multile octets" do
      n = VariableLengthQuantity.encode(0x00100000)
      assert n === <<0xC0, 0x80, 0x00>>
    end

    test "big number" do
      n = VariableLengthQuantity.encode(0x0FFFFFFF)
      assert n === <<0xFF, 0xFF, 0xFF, 0x7F>>
    end
  end

  test "santity checks" do
    a = 0x00
    a_ = VariableLengthQuantity.encode(a)
    {a__, ""} = VariableLengthQuantity.parse(a_)
    assert a === a__

    b = 0x001FFFFF
    b_ = VariableLengthQuantity.encode(b)
    {b__, ""} = VariableLengthQuantity.parse(b_)
    assert b === b__

    c = 0x0FFFFFFF
    c_ = VariableLengthQuantity.encode(c)
    {c__, ""} = VariableLengthQuantity.parse(c_)
    assert c === c__
  end
end
