defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, temp: "3000")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>

    <div id="light" phx-window-keyup="update">
      <div class="meter">
        <span style={"width: #{@brightness}%; background: #{temp_color(@temp)}"}>
          <%= @brightness %>%
        </span>
      </div>
      
      <form phx-change="update-light">
        <input
          type="range"
          min="0"
          max="100"
          name="brightness"
          value={@brightness}
          phx-debounce="250"
        />
      </form>
      
      <button phx-click="off">
        <img src="/images/light-off.svg" />
      </button>
      
      <button phx-click="down">
        <img src="/images/down.svg" />
      </button>
      
      <button phx-click="random">
        <img src="/images/fire.svg" />
      </button>
      
      <button phx-click="up">
        <img src="/images/up.svg" />
      </button>
      
      <button phx-click="on">
        <img src="/images/light-on.svg" />
      </button>
      
      <form phx-change="temp-change">
        <div class="temps">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input
                type="radio"
                id={temp}
                name="temp"
                value={temp}
                checked={@temp == temp}
              /> <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("update", %{"key" => "ArrowUp"}, socket) do
    {:noreply, increase_light(socket)}
  end

  def handle_event("update", %{"key" => "ArrowDown"}, socket) do
    {:noreply, decrease_light(socket)}
  end

  def handle_event("update", _, socket) do
    {:noreply, socket}
  end

  def handle_event("on", _payload, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("off", _payload, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("up", _payload, socket) do
    {:noreply, increase_light(socket)}
  end

  def handle_event("down", _payload, socket) do
    {:noreply, decrease_light(socket)}
  end

  def handle_event("random", _payload, socket) do
    socket = update(socket, :brightness, fn _x -> :rand.uniform(100) end)
    {:noreply, socket}
  end

  def handle_event("update-light", %{"brightness" => b}, socket) do
    socket = assign(socket, brightness: String.to_integer(b))

    {:noreply, socket}
  end

  def handle_event("temp-change", %{"temp" => temp}, socket) do
    socket = assign(socket, temp: temp)
    {:noreply, socket}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"

  def increase_light(socket) do
    update(socket, :brightness, &min(&1 + 10, 100))
  end

  def decrease_light(socket) do
    update(socket, :brightness, &max(&1 - 10, 0))
  end
end
