# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Crud.Repo.insert!(%Crud.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Query
alias Crud.Repo
alias Crud.Blog

# Hapus data existing untuk menghindari duplikat saat menjalankan ulang seeder
Repo.delete_all(from c in Blog.Category, where: c.id > 0)
Repo.delete_all(from t in Blog.Tag, where: t.id > 0)

# ============ SEED CATEGORIES ============
category_names = [
  "category 1",
  "category 2",
  "category 3",
  "category 4",
  "category 5"
]

for name <- category_names do
  Blog.create_category(%{name: name})
end

# ============ SEED TAGS ============
tag_names = [
  "tag 1",
  "tag 2",
  "tag 3",
  "tag 4",
  "tag 5"
]

for name <- tag_names do
  Blog.create_tag(%{name: name})
end

IO.puts("Seeded #{length(category_names)} categories and #{length(tag_names)} tags!")
