defmodule Nyt.PuzzleData do
  defstruct year: "2000",
            month: "01",
            day: "01",
            title: "",
            publisher: "",
            editor: "",
            copyright: "",
            across_clues: [],
            down_clues: [],
            grid: [],
            gridnums: [],
            guesses: [],
            rows: 0,
            cols: 0,
            cursor_index: 0,
            typing_direction: :across

  def get_by_date(year, month, day) do
    case load_puzzle_data(year, month, day) do
      {:ok, raw_data} ->
        {:ok,
         %__MODULE__{
           year: year,
           month: month,
           day: day,
           title: raw_data["title"],
           publisher: raw_data["publisher"],
           editor: raw_data["editor"],
           copyright: raw_data["copyright"],
           across_clues: raw_data["clues"]["across"],
           down_clues: raw_data["clues"]["down"],
           grid: raw_data["grid"],
           gridnums: raw_data["gridnums"],
           guesses: Enum.map(raw_data["grid"], fn _ -> nil end),
           rows: raw_data["size"]["rows"],
           cols: raw_data["size"]["cols"],
           cursor_index: 0,
           # or :down
           typing_direction: :across
         }}

      _ ->
        {:error, "unkown match"}
    end
  end

  def set_cursor_index(puzzle_data, index) do
    %__MODULE__{puzzle_data | cursor_index: index}
  end

  def set_typing_direction(%__MODULE__{typing_direction: :across} = puzzle_data) do
    %__MODULE__{puzzle_data | typing_direction: :down}
  end

  def set_typing_direction(%__MODULE__{typing_direction: :down} = puzzle_data) do
    %__MODULE__{puzzle_data | typing_direction: :across}
  end

  def set_typing_direction(puzzle_data, direction) do
    %__MODULE__{puzzle_data | typing_direction: direction}
  end

  def set_guess(puzzle_data, index, guess) do
    %__MODULE__{
      puzzle_data
      | guesses:
          List.update_at(
            puzzle_data.guesses,
            index,
            &(&1 = guess)
          )
    }
  end

  defp load_puzzle_data(year, month, day) do
    padded_month = String.pad_leading(month, 2, "0")
    padded_day = String.pad_leading(day, 2, "0")
    file_path = "priv/static/nyt_crosswords/#{year}/#{padded_month}/#{padded_day}.json"

    case File.read(file_path) do
      {:ok, content} -> Jason.decode(content)
      {:error, :enoent} -> {:error, "Puzzle not found"}
    end
  end

  def get_row(puzzle_data, index) do
    elem(get_coords(puzzle_data, index), 1)
  end

  def get_col(puzzle_data, index) do
    elem(get_coords(puzzle_data, index), 0)
  end

  def get_coords(%__MODULE__{rows: rows, cols: cols}, index)
      when index >= 0 and index < rows * cols do
    row = div(index, cols)
    col = rem(index, cols)
    {row, col}
  end

  def get_coords(_, _) do
    {-1, -1}
  end

  def step(
        %__MODULE__{typing_direction: :down, rows: rows, cols: cols, cursor_index: cursor_index} =
          puzzle_data,
        direction
      ) do
    new_index = cursor_index + cols * direction

    case new_index < rows * cols and new_index >= 0 do
      true ->
        %__MODULE__{puzzle_data | cursor_index: new_index}

      _ ->
        puzzle_data
    end
  end

  def step(
        %__MODULE__{typing_direction: :across, rows: rows, cols: cols, cursor_index: cursor_index} =
          puzzle_data,
        direction
      ) do
    new_index = cursor_index + direction

    case new_index < rows * cols and new_index >= 0 do
      true ->
        %__MODULE__{puzzle_data | cursor_index: new_index}

      _ ->
        puzzle_data
    end
  end

  def step(%__MODULE__{} = puzzle_data, _) do
    puzzle_data
  end
end
