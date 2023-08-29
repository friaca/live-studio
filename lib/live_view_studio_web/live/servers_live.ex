defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()
    changeset = Servers.change_server(%Server{})

    socket =
      assign(socket,
        servers: servers,
        coffees: 0,
        form: to_form(changeset)
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)
    {:noreply, assign(socket, selected_server: server, page_title: "Server #{server.name}")}
  end

  def handle_params(_, _uri, socket) do
    case socket.assigns.live_action do
      :new ->
        changeset = Servers.change_server(%Server{})

        socket =
          socket
          |> assign(:selected_server, nil)
          |> assign(:form, to_form(changeset))

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
            <.server_form form={@form}></.server_form>
          <% else %>
            <.server server={@selected_server} />
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

  def server_form(assigns) do
    ~H"""
    <.form for={@form} phx-submit="save" phx-change="validate">
      <div class="field">
        <.input
          field={@form[:name]}
          placeholder="Name"
          autocomplete="off"
          phx-debounce="1000"
        />
      </div>
      <div class="field">
        <.input
          field={@form[:framework]}
          placeholder="Framework"
          autocomplete="off"
          phx-debounce="1000"
        />
      </div>
      <div class="field">
        <.input
          field={@form[:size]}
          placeholder="Size (MB)"
          type="number"
          phx-debounce="1000"
        />
      </div>
      <.button phx-disable-with="Saving...">
        Save
      </.button>
      <.link patch={~p"/servers"} class="cancel">
        Cancel
      </.link>
    </.form>
    """
  end

  def server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @server.name %></h2>
        <span class={@server.status}>
          <%= @server.status %>
        </span>
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

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        changeset = Servers.change_server(%Server{})

        socket =
          socket
          |> assign(:form, to_form(changeset))
          |> update(:servers, fn servers -> [server | servers] end)
          |> push_patch(to: ~p"/servers/#{server.id}")

        {:noreply, socket}

      {:error, changeset} ->
        socket = socket |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(form: to_form(changeset))

    {:noreply, socket}
  end
end
