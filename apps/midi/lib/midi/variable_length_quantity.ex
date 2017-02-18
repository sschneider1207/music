defmodule MIDI.VariableLengthQuantity do
  @moduledoc """
  Variable-length quantity is an encoding that uses an arbitary number of
  octets to represent an arbitrarily large integer.  It was designed for use
  in MIDI files in order to save space with regards to 32-bit integers.
  """

  @doc """
  Parses a variable length quantity integer off the head of a binary.
  """
  @spec parse(binary) :: {integer, binary} | :error
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
  defp do_parse(_, _) do
    :error
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
    do_encode(int)
  end

  use Bitwise, only_operators: true

  defp do_encode(int, acc \\ [])
  defp do_encode(0, []) do
    <<0x00>>
  end
  defp do_encode(0, acc) do
    Enum.reduce(acc, <<>>, &Kernel.<>(&2, &1))
  end
  defp do_encode(int, []) do
    n = int &&& 127
    do_encode(int >>> 7, [<<0 :: 1, n :: 7>>])
  end
  defp do_encode(int, acc) do
    n = int &&& 127
    do_encode(int >>> 7, [<<1 :: 1, n :: 7>>|acc])
  end
end
