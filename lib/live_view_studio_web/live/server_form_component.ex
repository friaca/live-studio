defmodule LiveViewStudioWeb.ServerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(socket) do
    changeset = Servers.change_server(%Server{})

    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
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
    </div>
    """
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        changeset = Servers.change_server(%Server{})

        socket =
          socket
          |> assign(:form, to_form(changeset))
          |> push_patch(to: ~p"/servers/#{server}")

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
