defmodule MIDI.Chunk do
  @header "MThd"
  @track "MTrk"
  alias MIDI.Event
  
  defmodule Header do
    defstruct [:format, :num_tracks, :pulses_per_quarter_note]
  end

  defmodule Track do
    defstruct [:events]
  end

  @type chunk :: header | track
  @type header :: %Header{}
  @type track :: %Track{}

  @doc """
  Parses a binary midi file into a list of chunks.
  """
  @spec parse(binary) :: [chunk]
  def parse(bin) do
    Stream.unfold(bin, fn
      "" -> nil
      bytes ->  parse_chunk(bytes)
    end)
    |> Enum.to_list()
  end

  defp parse_chunk(<<@header,
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
  defp parse_chunk(<<@track,
                    length :: 32,
                    bin :: binary>>)
  do
    <<events :: size(length)-binary, rest :: binary>> = bin
    track = struct(Track, events: Event.parse(events))
    {track, rest}
  end

  defp format(0), do: :single
  defp format(1), do: :multi_simultaneous
  defp format(2), do: :multi_sequentially
  defp format(_), do: :unknown
end
