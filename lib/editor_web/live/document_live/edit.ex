defmodule EditorWeb.DocumentLive.Edit do
  use EditorWeb, :live_view

  alias Editor.Documents
  alias Editor.Accounts
  alias EditorWeb.DocumentPresence

  @impl true
  def mount(_params, session, socket) do
    EditorWeb.Endpoint.subscribe(DocumentPresence.topic())

    {:ok, socket |> assign(user: Accounts.get_user_by_session_token(session["user_token"]))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    document = Documents.get_document!(id)

    maybe_track_user(document, socket)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:document, document)
     |> assign(:changeset, Documents.change_document(document))}
  end

  @spec maybe_track_user(Map.t(), Map.t()) :: nil | {:error, any} | {:ok, binary}
  def maybe_track_user(
        document,
        %{assigns: %{live_action: :edit, user: user}} = socket
      ) do
    if connected?(socket) do
      DocumentPresence.track_user(self(), document.id, user.email)
    end
  end

  def maybe_track_user(_docment, _socket), do: nil

  @impl true
  def handle_event("validate", %{"document" => document_params}, socket) do
    changeset =
      socket.assigns.document
      |> Documents.change_document(document_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"document" => document_params}, socket) do
    save_document(socket, document_params)
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    send_update(EditorWeb.DocumentActivityLive,
      id: "doc#{socket.assigns.document.id}",
      document: socket.assigns.document
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event: "document_saved", payload: %{from_pid: from_pid, id: id}},
        socket
      )
      when id == socket.assigns.document.id do
    socket =
      if from_pid != self() do
        document = Documents.get_document!(id)
        changeset = Documents.change_document(document)

        socket
        |> assign(:document, document)
        |> assign(:changeset, changeset)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "document_saved"}, socket), do: {:noreply, socket}

  defp page_title(:show), do: "Show Document"
  defp page_title(:edit), do: "Edit Document"

  defp save_document(socket, document_params) do
    case Documents.update_document(socket.assigns.document, document_params) do
      {:ok, document} ->
        EditorWeb.Endpoint.broadcast(DocumentPresence.topic(), "document_saved", %{
          id: document.id,
          from_pid: self()
        })

        {:noreply,
         socket
         |> assign(:changeset, Documents.change_document(document))
         |> assign(:document, document)
         |> put_flash(:info, "Document updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
