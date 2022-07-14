defmodule Exi.Factory do
  use ExMachina.Ecto, repo: Exi.Repo
  # alias Exi.Schemas.User

  def user_factory(attrs \\ %{}) do
    %{
      telegram_id: sequence(:telegram_id, & &1),
      username: sequence(:username, &"username_#{&1}")
    }
    |> Map.merge(attrs)
  end
end
