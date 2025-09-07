defmodule NytWeb.PuzzleComponents do
  use Phoenix.Component
  alias Nyt.PuzzleData

  # alias Phoenix.LiveView.JS
  use NytWeb, :html

  attr :puzzle_data, Map
  attr :error, :string

  def puzzle_dbg(assigns) do
    ~H"""
    <p :if={@error}>Error: {@error}</p>
    <pre :if={@puzzle_data}><%= inspect(@puzzle_data) %></pre>
    """
  end

  attr :title, :string
  attr :clues, :list

  def clue_list(assigns) do
    ~H"""
    <div class="p-2">
      <h3 class="text-lg font-semibold">{@title}</h3>
      <ul>
        <%= for clue <- @clues do %>
          <li class="hover:bg-green-300">{clue}</li>
        <% end %>
      </ul>
    </div>
    """
  end

  attr :index, :integer
  attr :row, :integer
  attr :col, :integer
  attr :id, :string
  attr :gridnum, :integer
  attr :grid, :string
  attr :guess, :string, default: ""
  attr :current, :boolean, default: false
  attr :highlighted, :boolean, default: false

  def board_cell(assigns) do
    ~H"""
    <div
      id={@id}
      index={@index}
      phx-click="on_focus_changed"
      phx-value-index={@index}
      class={[
        "w-16 h-16 border border-gray-100 flex relative items-center justify-center",
        @grid == "." && "bg-black",
        @current && @grid != "." && "bg-red-200",
        @highlighted && @grid != "." && "bg-green-200"
      ]}
    >
      <span :if={@gridnum != 0} class="absolute top-1 left-1 text-xs">{@gridnum}</span>
      <%!-- <span class="absolute top-1 right-1 text-xs bg-orange-100 rounded-sm">
        {@index} ({@row}, {@col})
      </span> --%>
      <input
        phx-focus="on_focus_changed"
        phx-value-index={@index}
        phx-keyup="on_key_up"
        class="w-16 h-16 text-center text-xl bg-none focus:bg-none"
        maxlength="1"
        value={@guess}
      />
    </div>
    """
  end

  attr :cols, :integer
  slot :inner_block, required: true

  def board(assigns) do
    ~H"""
    <div
      style={"grid-template-columns: repeat(#{@cols}, minmax(0, 1fr))"}
      class="grid border-red-500 border bg-white text-black"
    >
      {render_slot(@inner_block)}
    </div>
    """
  end


  attr :puzzle_data, PuzzleData

  def puzzle_header(assigns) do
    ~H"""
    <div class="flex">
      <div class="flex-1">
        <h1 class="text-xl font-bold">{@puzzle_data.title}</h1>
        <h2 class="text-lg font-semibold">
          {@puzzle_data.editor} &copy; {@puzzle_data.copyright}
        </h2>
      </div>
      <div>
        <span class="badge ">
          idx: {@puzzle_data.cursor_index} cell: {inspect(
            PuzzleData.get_coords(@puzzle_data, @puzzle_data.cursor_index)
          )}
        </span>

        <button
          class={[
            "btn text-xl font-bold",
            @puzzle_data.typing_direction == :across && "btn-primary"
          ]}
          phx-click="on_typing_direction_changed"
          phx-value-direction="across"
        >
          <.icon name="hero-arrow-right" /> Across
        </button>
        <button
          class={[
            "btn text-xl font-bold",
            @puzzle_data.typing_direction == :down && "btn-primary"
          ]}
          phx-click="on_typing_direction_changed"
          phx-value-direction="down"
        >
          <.icon name="hero-arrow-down" /> Down
        </button>
      </div>
    </div>
    """
  end
end
