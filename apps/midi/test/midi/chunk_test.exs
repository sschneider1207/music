defmodule MIDI.ChunkTest do
  use ExUnit.Case
  alias MIDI.Chunk
  alias MIDI.Chunk.{Header, Track}
  @path Path.expand("../../priv", __DIR__) |> Path.join("market.mid")

  describe "ocarina of time market theme" do
    # http://phpmidiparser.com/reports/1815/
    
    setup do
      bytes = File.read!(@path)
      {:ok, [bytes: bytes]}
    end

    test "header parsed correctly", %{bytes: bytes} do
      {header, _} = Chunk.parse_chunk(bytes)

      assert header.__struct__ === Header
      assert header.format === :multi_simultaneous
      assert header.num_tracks === 8
      assert header.pulses_per_quarter_note === 480
    end

  end
end
