defmodule Editor.Repo do
  use Ecto.Repo,
    otp_app: :editor,
    adapter: Ecto.Adapters.Postgres
end
