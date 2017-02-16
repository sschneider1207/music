defmodule MIDI.Chunk do
  @header "MThd"
  @track "MTrk"

  defmodule Header do
    defstruct [:format, :num_tracks, :pulses_per_quarter_note]
  end

  defmodule Track do
    defstruct [:events]
  end

  def parse_chunk(<<@header,
                     6        :: 32,
                     format   :: 16,
                     ntrks    :: 16,
                     division :: 16,
                     rest     :: binary>>)
  do
    header = struct(Header, [
      format: format(format),
      num_tracks: (if ntrks === 0, do: nil, else: ntrks),
      pulses_per_quarter_note: division
    ])
    {header, rest}
  end
  def parse_chunk(<<@track,
                    length :: 16,
                    bin :: binary>>)
  do
    <<track :: size(length), rest :: binary>> = bin
    track = struct(Track, events: parse_track(track))
    {track, rest}
  end

  defp parse_track(bin) do
    :ok
  end

  defp format(0), do: :single
  defp format(1), do: :multi_simultaneous
  defp format(2), do: :multi_sequentially
  defp format(_), do: :unknown
end
