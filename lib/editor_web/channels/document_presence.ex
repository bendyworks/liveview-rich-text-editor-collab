defmodule EditorWeb.DocumentPresence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :editor,
    pubsub_server: Editor.PubSub

  @activity_topic "document_activity"

  @spec track_user(pid, Integer.t(), String.t()) :: {:error, any} | {:ok, binary}
  def track_user(pid, document_id, user_email) do
    track(pid, @activity_topic, document_id, %{users: [%{email: user_email}]})
  end

  @spec topic() :: String.t()
  def topic(), do: @activity_topic

  @spec list_users_for(Integer.t()) :: List.t()
  def list_users_for(document_id) do
    users = list(@activity_topic)

    users
    |> Map.get(to_string(document_id), %{metas: []})
    |> Map.get(:metas)
    |> users_from_metas
  end

  defp users_from_metas(metas) do
    Enum.map(metas, &get_in(&1, [:users]))
    |> List.flatten()
    |> Enum.map(&Map.get(&1, :email))
    |> Enum.uniq()
  end
end
