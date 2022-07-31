defmodule Exi.Users do
  alias Exi.Users.User
  alias Exi.Repo

  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
