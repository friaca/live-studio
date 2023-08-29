defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    socket =
      assign(socket,
        volunteers: volunteers,
        form: to_form(changeset)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.form for={@form} phx-submit="save" phx-change="validate">
        <.input
          field={@form[:name]}
          placeholder="Name"
          autocomplete="off"
          phx-debounce="2000"
        />
        <.input
          field={@form[:phone]}
          type="tel"
          placeholder="Phone"
          phx-debounce="blur"
        />
        <.button phx-disable-with="Saving...">
          Check-in
        </.button>
      </.form>
      <div
        :for={volunteer <- @volunteers}
        class={"volunteer #{if volunteer.checked_out, do: "out"}"}
      >
        <div class="name">
          <%= volunteer.name %>
        </div>
        <div class="phone">
          <%= volunteer.phone %>
        </div>
        <div class="status">
          <button>
            <%= if volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->
        changeset = Volunteers.change_volunteer(%Volunteer{})

        socket =
          socket
          |> assign(form: to_form(changeset))
          |> update(:volunteers, fn v -> [volunteer | v] end)
          |> put_flash(:info, "Volunteer successfully checked in!")

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(form: to_form(changeset))
          |> put_flash(:error, "Couln't checkin volunteer!")

        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(form: to_form(changeset))

    {:noreply, socket}
  end
end
