defmodule CrudWeb.PostLive.Form do
  use CrudWeb, :live_view

  alias Crud.Blog
  alias Crud.Blog.Post

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="post-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:body]} type="textarea" label="Body" />
        <.input field={@form[:category_id]} type="select" label="Category" options={@category_options} />
        <.input field={@form[:tag_ids]} type="select" label="Tags" multiple options={@tag_options} />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Post</.button>
          <.button navigate={return_path(@return_to, @post)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end


  @impl true
  def mount(params, _session, socket) do
    socket =
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign_select_options() # Menambahkan opsi kategori ke socket
     |> apply_action(socket.assigns.live_action, params)

    {:ok, socket}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  # memanggil fungsi edit dengan parameter id untuk mengambil data post yang akan diedit
  defp apply_action(socket, :edit, %{"id" => id}) do
    post = Blog.get_post!(id)

    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
    |> assign(:form, to_form(Blog.change_post(post)))
  end

  # memanggil fungsi new untuk membuat data post baru
  defp apply_action(socket, :new, _params) do
    post = %Post{}

    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, post)
    |> assign(:form, to_form(Blog.change_post(post)))
  end

  # Fungsi untuk mengambil kategori dan tag kemudian mengubahnya menjadi opsi untuk select input
  defp assign_select_options(socket) do
    socket
    |> assign(:category_options, Enum.map(Blog.list_categories(), &{&1.name, &1.id})) # Menambahkan opsi kategori ke socket
    |> assign(:tag_options, Enum.map(Blog.list_tags(), &{&1.name, &1.id})) # Menambahkan opsi tag ke socket
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset = Blog.change_post(socket.assigns.post, post_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.live_action, post_params)
  end

  # dipanggil ketika :edit. kemudian panggil fungsi update_post dari Blog untuk mengupdate data post
  defp save_post(socket, :edit, post_params) do
    case Blog.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, post))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  #dipanggil ketika :new, kemudian panggil fungsi create_post dari Blog untuk membuat data post baru
  defp save_post(socket, :new, post_params) do
    case Blog.create_post(post_params) do
      {:ok, post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, post))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _post), do: ~p"/posts"
  defp return_path("show", post), do: ~p"/posts/#{post}"
end
