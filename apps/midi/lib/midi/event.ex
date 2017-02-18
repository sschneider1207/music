defmodule MIDI.Event do
  alias MIDI.VariableLengthQuantity

  def parse_events(bin) do

  end

  defp parse_event(bin) do
    {delta_time, rest} = VariableLengthQuantity.parse(bin)
  end
end
