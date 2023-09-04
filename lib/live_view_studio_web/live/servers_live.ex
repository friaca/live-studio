defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudioWeb.ServerFormComponent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Servers.subscribe()
    end

    servers = Servers.list_servers()

    socket =
      socket
      |> assign(:servers, servers)
      |> assign(:coffees, 0)

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)
    {:noreply, assign(socket, selected_server: server, page_title: "Server #{server.name}")}
  end

  def handle_params(_, _uri, socket) do
    case socket.assigns.live_action do
      :new ->
        socket =
          socket
          |> assign(:selected_server, nil)

        {:noreply, socket}

      _ ->
        {:noreply, assign(socket, selected_server: hd(socket.assigns.servers))}
    end
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link patch={~p"/servers/new"} class="add">
            + Add New Server
          </.link>
          <.link
            :for={server <- @servers}
            patch={~p"/servers/#{server}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <.live_component module={ServerFormComponent} id={:new} />
          <% else %>
            <.server socket={@socket} server={@selected_server} />
          <% end %>
          <div class="links">
            <.link navigate={~p"/light"}>
              Adjust lights
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @server.name %></h2>
        <button
          id="copy-server-url"
          data-content={url(@socket, ~p"/servers/#{@server.id}")}
          phx-hook="Clipboard"
        >
          Copy URL
        </button>
        <button
          class={@server.status}
          phx-click="toggle-status"
          phx-value-id={@server.id}
        >
          <%= @server.status %>
        </button>
      </div>
      <div class="body">
        <div class="row">
          <span>
            <%= @server.deploy_count %> deploys
          </span>
          <span>
            <%= @server.size %> MB
          </span>
          <span>
            <%= @server.framework %>
          </span>
        </div>
        <h3>Last Commit Message:</h3>
        <blockquote>
          <%= @server.last_commit_message %>
        </blockquote>
      </div>
    </div>
    """
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)
    {:ok, _server} = Servers.toggle_status(server)

    {:noreply, socket}
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_info({:server_created, server}, socket) do
    socket =
      socket
      |> update(:servers, fn servers -> [server | servers] end)

    {:noreply, socket}
  end

  def handle_info({:server_updated, server}, socket) do
    servers =
      Enum.map(socket.assigns.servers, fn s ->
        if s.id == server.id, do: server, else: s
      end)

    case socket.assigns.selected_server do
      %{id: id} when id == server.id ->
        socket =
          socket
          |> assign(:servers, servers)
          |> assign(:selected_server, server)

        {:noreply, socket}

      _ ->
        socket =
          socket
          |> assign(:servers, servers)

        {:noreply, socket}
    end
  end

  def handle_info({:server_deleted, server}, socket) do
    servers = Enum.filter(socket.assigns.servers, &(&1.id == server.id))

    socket =
      socket
      |> assign(:servers, servers)

    {:noreply, socket}
  end
end
