defmodule Exi.Users do
  alias Exi.Schemas.User
  alias Exi.Repo

  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
