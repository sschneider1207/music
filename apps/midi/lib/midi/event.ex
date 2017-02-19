defmodule MIDI.Event do
  alias MIDI.VariableLengthQuantity
  alias Midi.Event.{MIDIEvent, SysExEvent, MetaEvent}

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
    {event, rest} = case rest do
      <<0xFF :: 8, _ :: binary>> ->
        MetaEvent.parse(rest)
      <<byte :: 8, _ :: binary>> when byte in [0xF0, 0xF7] ->
        SysExEvent.parse(rest)
      _ ->
        MIDIEvent.parse(rest)
    end
  end
end
