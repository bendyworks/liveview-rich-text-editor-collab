defmodule EditorWeb.DocumentLive.Edit do
  use EditorWeb, :live_view

  alias Editor.Documents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    document = Documents.get_document!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:document, document)
     |> assign(:changeset, Documents.change_document(document))}
  end

  defp page_title(:show), do: "Show Document"
  defp page_title(:edit), do: "Edit Document"

  @impl true
  def handle_event("validate", %{"document" => document_params}, socket) do
    IO.inspect(document_params)

    changeset =
      socket.assigns.document
      |> Documents.change_document(document_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"document" => document_params}, socket) do
    save_document(socket, document_params)
  end

  defp save_document(socket, document_params) do
    case Documents.update_document(socket.assigns.document, document_params) do
      {:ok, _document} ->
        {:noreply,
         socket
         |> put_flash(:info, "Document updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
