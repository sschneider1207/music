defmodule MIDI.Parser do
  @header "MThd"
  @track "MTrk"

  def parse_file(path) do
    with {:ok, bytes} <- File.read(path),
         {:ok, midi} <- parse_bytes(bytes)
    do
      {:ok, midi}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def parse_bytes(bytes) do

  end
end
