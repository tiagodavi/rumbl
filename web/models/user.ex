defmodule Rumbl.User do
	use Rumbl.Web, :model

	schema "users" do
		field :name, :string
		field :username, :string
		field :password, :string, virtual: true
		field :password_hash, :string

		timestamps
	end

  @required_fields ~w(name username)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:username, min: 1, max: 20)
  end
end
