defmodule MIDI.Event do
  alias MIDI.VariableLengthQuantity

  @doc """
  Parses a binary block into a list of midi events.
  """
  @spec parse(binary) :: []
  def parse(bin) do
    Stream.unfold(bin, fn
      "" -> nil
      bytes -> parse_event(bytes)
    end)
    |> Enum.to_list()
  end

  defp parse_event(bin) do
    {delta_time, rest} = VariableLengthQuantity.parse(bin)
    {delta_time, ""}
  end
end
