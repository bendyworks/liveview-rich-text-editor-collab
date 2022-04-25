defmodule Editor.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Editor.Documents` context.
  """

  @doc """
  Generate a document.
  """
  def document_fixture(attrs \\ %{}) do
    {:ok, document} =
      attrs
      |> Enum.into(%{
        data: "some data",
        name: "some name"
      })
      |> Editor.Documents.create_document()

    document
  end
end
