defmodule CssClash.TargetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CssClash.Targets` context.
  """

  @doc """
  Generate a target.
  """
  def target_fixture(attrs \\ %{}) do
    {:ok, target} =
      attrs
      |> Enum.into(%{
        colors: ["#fff", "#ccc"],
        image_data: "some image_data",
        name: "some name"
      })
      |> CssClash.Targets.create_target()

    target
  end
end
