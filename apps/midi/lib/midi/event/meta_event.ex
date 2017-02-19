defmodule MIDI.Event.MetaEvent do
  alias MIDI.VariableLengthQuantity
  defstruct [:type, :data]
  @header 0xFF
  @seq_num 0x00
  @text 0x01
  @copyright 0x02
  @track_name 0x03
  @instrument_name 0x04
  @lyric 0x05
  @marker 0x06
  @cue_point 0x07
  @channel_prefix 0x20
  @end_of_track 0x2F
  @set_tempo 0x51
  @smpte_offset 0x54
  @time_signature 0x58
  @key_signature 0x59
  @sequencer_specific 0x7F
  @text_events [@text, @copyright, @track_name,
                @instrument_name, @lyric, @marker, @cue_point]


  def parse(bin) do
    do_parse(bin)
  end

  defp do_parse(<<@header, @seq_num, 0x02, seq_num :: 16, rest :: binary>>) do
    {struct(__MODULE__, type: :sequence_number, data: seq_num), rest}
  end
  defp do_parse(<<@header, header :: 8, rest :: binary>>) when header in @text_events do
    {len, rest} = VariableLengthQuantity.parse(rest)
    <<text :: size(len)-unit(1)-binary, rest :: binary>> = rest
    {struct(__MODULE__, type: text_type(header), data: text), rest}
  end
  defp do_parse(<<@header, @channel_prefix, 0x01, cc :: 8, rest :: binary>>) do
    {struct(__MODULE__, type: :channel_prefix, data: cc), rest}
  end
  defp do_parse(<<@header, @end_of_track, 0x00, rest :: binary>>) do
    {struct(__MODULE__, type: :end_of_track), rest}
  end
  defp do_parse(<<@header, @set_tempo, 0x03, temp :: 24, rest :: binary>>) do
    {struct(__MODULE__, type: :set_tempo, data: temp), rest}
  end
  defp do_parse(<<@header, @smpte_offset, 0x05, 0 :: 1, rr :: 2, hr :: 6,
                  mm :: 8, se :: 8, fr :: 8, ff :: 8, rest :: binary>>)
  do
    rate = case rr do
      0 -> 24.00
      1 -> 25.00
      2 -> 29.97
      3 -> 30.00
    end
    data = [rate: rate, hour: hr, minute: mm,
            sec: se, frame: fr, fractional_frames: ff]
    {struct(__MODULE__, type: :smpte_offset, data: data), rest}
  end
  defp do_parse(<<@header, @time_signature, 0x04, nn :: 8,
                  dd :: 8, cc :: 8, bb :: 8, rest :: binary>>)
  do
    denom = :math.pow(2, dd) |> round()
    data = [numerator: nn, denominator: denom,
            notated_32nd_nodes_per_quarter_note: bb,
            clocks_per_metronome_click: cc]
    {struct(__MODULE__, type: :time_signature, data: data), rest}
  end
  defp do_parse(<<@header, @key_signature, 0x02, sf :: 8,
                  mi :: 8, rest :: binary>>)
  do
    key = key(sf, mi)
    {struct(__MODULE__, type: :key_signature, data: key), rest}
  end

  defp text_type(@text),            do: :text
  defp text_type(@copyright),       do: :copyright
  defp text_type(@track_name),      do: :track_name
  defp text_type(@instrument_name), do: :instrument_name
  defp text_type(@lyric),           do: :lyric
  defp text_type(@marker),          do: :marker
  defp text_type(@cue_point),        do: :tecuepointxt

  @major_keys ~w(c g d a e b f_sharp c_sharp f b_flat
                 e_flat a_flat d_flat g_flat c_flat)a
  @minor_keys ~w(a e b f_sharp c_sharp g_sharp d_sharp
                 a_sharp d g c f b_flat e_flat a_flat)a
  defp key(accedentals, major_flag) do
    index = cond do
      accedentals >= 0 -> accedentals
      true -> abs(accedentals) + 7
    end
    case major_flag do
      0 -> {Enum.take(@major_keys, index), :major}
      1 -> {Enum.take(@minor_keys, index), :minor}
    end
  end
end
