# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CssClash.Repo.insert!(%CssClash.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias CssClash.Targets

Targets.create_target(%{
  name: "Target 1",
  image_data: File.read!("priv/repo/seed_target_images/target_1.png"),
  colors: ["#FF0000", "#FFF"]
})
