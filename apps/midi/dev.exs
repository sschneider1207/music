alias MIDI.Chunk
path = ~S"E:\elixir\music\apps\midi\priv\market.mid"
bin = File.read!(path)
{header, rest} = Chunk.parse_chunk(bin)
{track1, rest} = Chunk.parse_chunk(rest)

IO.inspect header, label: "header"
IO.inspect track1, label: "track1"
