defmodule NytWeb.CrosswordPuzzleLive do
  use NytWeb, :live_view
  alias Nyt.PuzzleData

  import NytWeb.PuzzleComponents,
    only: [puzzle_dbg: 1, clue_list: 1, board_cell: 1, board: 1, puzzle_header: 1]

  def mount(%{"year" => year, "month" => month, "day" => day}, _session, socket) do
    socket =
      socket
      |> assign(:puzzle_data, nil)
      |> assign(:error, nil)
      |> assign(:dbg, false)

    socket =
      case PuzzleData.get_by_date(year, month, day) do
        {:ok, puzzle_data} ->
          assign(socket, :puzzle_data, puzzle_data)

        {:error, error} ->
          assign(socket, :error, error)
      end

    {:ok, socket}
  end

  def handle_event("on_focus_changed", %{"index" => index}, socket) do
    case String.to_integer(index) == socket.assigns.puzzle_data.cursor_index do
      true ->
        {:noreply,
         socket
         |> assign(
           :puzzle_data,
           PuzzleData.set_typing_direction(socket.assigns.puzzle_data)
         )}

      false ->
        {:noreply,
         socket
         |> assign(
           :puzzle_data,
           PuzzleData.set_cursor_index(socket.assigns.puzzle_data, String.to_integer(index))
         )}
    end
  end

  def handle_event(
        "on_typing_direction_changed",
        %{"direction" => direction},
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       :puzzle_data,
       PuzzleData.set_typing_direction(socket.assigns.puzzle_data, String.to_atom(direction))
     )}
  end

  def handle_event("on_key_up", %{"index" => _index, "key" => key}, socket) do
    cond do
      key =~ ~r/^[[:alpha:]]{1}$/ ->
        new_puzzle_data =
          socket.assigns.puzzle_data
          |> PuzzleData.set_guess(socket.assigns.puzzle_data.cursor_index, key)
          |> PuzzleData.step(1)

        {:noreply,
         socket
         |> assign(
           :puzzle_data,
           new_puzzle_data
         )}

      key == "Backspace" or key == "Delete" ->
        new_puzzle_data =
          socket.assigns.puzzle_data
          |> PuzzleData.set_guess(socket.assigns.puzzle_data.cursor_index, nil)
          |> PuzzleData.step(-1)

        {:noreply,
         socket
         |> assign(
           :puzzle_data,
           new_puzzle_data
         )}

      true ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="flex-1 flex bg-black text-white items-center justify-center h-screen">
        <div :if={@puzzle_data} class="flex flex-col">
          <.puzzle_header puzzle_data={@puzzle_data} />
          <.board cols={@puzzle_data.cols}>
            <.board_cell
              :for={
                {{gridnum, grid, guess}, index} <-
                  Enum.with_index(
                    Enum.zip([@puzzle_data.gridnums, @puzzle_data.grid, @puzzle_data.guesses])
                  )
              }
              index={index}
              gridnum={gridnum}
              grid={grid}
              guess={guess}
              id={"cell-#{index}"}
              current={index == @puzzle_data.cursor_index}
              highlighted={
                PuzzleData.get_col(@puzzle_data, index) ==
                  PuzzleData.get_col(@puzzle_data, @puzzle_data.cursor_index) or
                  PuzzleData.get_row(@puzzle_data, index) ==
                    PuzzleData.get_row(@puzzle_data, @puzzle_data.cursor_index)
              }
              col={PuzzleData.get_col(@puzzle_data, index)}
              row={PuzzleData.get_row(@puzzle_data, index)}
            />
          </.board>
          <div :if={@error}>
            <p class="text-lg text-red">
              MISSING DATA FOR THIS PUZZLE
            </p>
            <p class="text-lg text-red">
              {@error}
            </p>
          </div>
        </div>
        <div :if={@puzzle_data} class="max-h-screen overflow-scroll p-2">
          <h2 class="text-xl font-bold text-green-500">Clues</h2>
          <div class="flex">
            <.clue_list title="Across" clues={@puzzle_data.across_clues} />
            <.clue_list title="Down" clues={@puzzle_data.down_clues} />
          </div>
        </div>
        <div :if={@dbg} class="max-h-screen overflow-scroll">
          <.puzzle_dbg error={@error} puzzle_data={@puzzle_data} />
        </div>
      </div>
    </div>
    """
  end
end
