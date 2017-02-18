alias MIDI.Chunk
path = ~S"E:\elixir\music\apps\midi\priv\market.mid"
bin = File.read!(path)
Chunk.parse(bin)
|> IO.inspect(label: "chunks")
