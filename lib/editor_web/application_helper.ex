defmodule EditorWeb.ApplicationHelper do
  def gravatar(email) do
    hash =
      email
      |> String.trim()
      |> String.downcase()
      |> :erlang.md5()
      |> Base.encode16(case: :lower)

    # &d=identicon
    "https://www.gravatar.com/avatar/#{hash}?s=50"
  end
end
