defmodule LiveViewStudioWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :live_view_studio,
    pubsub_server: LiveViewStudio.PubSub

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, topic)
  end

  def track_user(user, topic, metadata \\ %{}) do
    default_meta = %{username: user.email |> String.split("@") |> hd()}
    new_meta = Map.merge(default_meta, metadata)

    track(self(), topic, user.id, new_meta)
  end

  def list_users(topic) do
    list(topic)
  end

  def update_user(user, topic, updates) do
    %{metas: [meta | _]} = get_by_key(topic, user.id)

    update(self(), topic, user.id, Map.merge(meta, updates))
  end

  def handle_diff(socket, diff) do
    socket
    |> remove_presences(diff.leaves)
    |> add_presences(diff.joins)
  end

  def remove_presences(socket, leaves) do
    user_ids = Enum.map(leaves, fn {user_id, _meta} -> user_id end)
    presences = Map.drop(socket.assigns.presences, user_ids)

    Phoenix.Component.assign(socket, :presences, presences)
  end

  def add_presences(socket, joins) do
    presences = Map.merge(socket.assigns.presences, simple_presence_map(joins))

    Phoenix.Component.assign(socket, :presences, presences)
  end

  def simple_presence_map(presences) do
    presences
    |> Enum.into(%{}, fn {user_id, %{metas: [meta | _]}} ->
      {user_id, meta}
    end)
  end
end
