defmodule EditorWeb.DocumentActivityLive do
  use EditorWeb, :live_component
  alias EditorWeb.DocumentPresence

  def update(%{document: document}, socket) do
    {:ok,
     socket
     |> assign(users: DocumentPresence.list_users_for(document.id))}
  end

  @spec render(Map.t()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    if assigns.users do
      ~H"""
      <ul class="active_users">
        <%= for user <- assigns.users do %>
          <li><img class="round" src={gravatar(user)} /></li>
        <% end %>
      </ul>
      """
    else
      ~H"""
      <ul class="active_users">
      </ul>
      """
    end
  end
end
