defmodule MIDI.Chunk do
  @header "MThd"
  @track "MTrk"
  alias MIDI.Event

  defmodule Header do
    defstruct [:format, :num_tracks, :division]
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
                     division :: 16-unit(1)-binary,
                     rest     :: binary>>)
  do
    header = struct(Header, [
      format: format(format),
      num_tracks: (if ntrks === 0, do: nil, else: ntrks),
      division: division(division)
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

  defp division(<<0 :: 1, ppq :: 15>>) do
    {:pulses_per_quarter_note, ppq}
  end
  defp division(<<1 :: 1, format :: 7, tpf :: 8>>) do
    smpte = case format do
      -24 ->24.00
      -25 -> 25.00
      -29 -> 29.97
      -30 -> 30.00
    end
    [smpte: smpte, ticks_per_frame: tpf]
  end
end
