defmodule MIDI.VariableLengthQuantity do

  @doc """
  Parses a variable length quantity integer off the head of a binary.
  """
  @spec parse(binary) :: {integer, binary}
  def parse(bin) do
    do_parse(bin)
  end

  defp do_parse(bin, acc \\ [])
  defp do_parse(<<0 :: 1, n :: 7, rest :: binary>>, acc) do
    quantity =
      :lists.reverse(acc, [n])
      |> list_to_quantity()
    {quantity, rest}
  end
  defp do_parse(<<1 :: 1, n :: 7, rest :: binary>>, acc) do
    do_parse(rest, [n|acc])
  end

  defp list_to_quantity(list) do
    {bin, length} = Enum.reduce list, {<<>>, 0}, fn
      c, {bin_acc, l} ->
        {<<bin_acc :: binary-size(l)-unit(1), c :: 7>>, l + 7}
    end
    <<quantity :: size(length)-unit(1)>> = bin
    quantity
  end

  @doc """
  Encodes an integer to a variable length quantity binary.
  """
  @spec encode(integer) :: binary
  def encode(int) do

  end
end
