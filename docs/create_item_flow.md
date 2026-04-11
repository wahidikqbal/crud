# Urutan Pemanggilan Fungsi Saat Proses Create Item

Dokumen ini menjelaskan alur lengkap saat user membuat item baru, dari klik tombol sampai data tersimpan di database.

---

## Diagram Alur (Overview)

```
User klik "New Item"
        ↓
ItemLive.Form mount (action: :new)
        ↓
Form ditampilkan ke user
        ↓
User isi form & klik "Save"
        ↓
handle_event("save", ...)
        ↓
save_item(..., :new, ...)
        ↓
Product.create_item(...)
        ↓
Item.changeset(...) → validasi
        ↓
Repo.insert(...) → simpan ke DB
        ↓
Redirect ke halaman list
```

---

## Tahap 1: User Mengklik Tombol "New Item"

**File:** `lib/crud_web/live/item_live/index.ex` (baris 13-15)

```elixir
<.button variant="primary" navigate={~p"/items/new"}>
  <.icon name="hero-plus" /> New Item
</.button>
```

**Penjelasan:**
- Tombol ini menggunakan `navigate={~p"/items/new"}`
- Browser akan berpindah ke route `/items/new`
- Phoenix Router mengaktifkan `ItemLive.Form` dengan `live_action = :new`

---

## Tahap 2: Mount dan Persiapan Form

### 2.1 Fungsi `mount/3` di `form.ex`

**File:** `lib/crud_web/live/item_live/form.ex` (baris 33-39)

```elixir
def mount(params, _session, socket) do
  {:ok,
   socket
    |> assign(:return_to, return_to(params["return_to"]))
    |> assign_select_options()
    |> apply_action(socket.assigns.live_action, params)}
end
```

**Penjelasan:**
- Dipanggil otomatis saat LiveView diaktifkan
- Menyiapkan data yang diperlukan untuk form

### 2.2 Fungsi `assign_select_options/1`

**File:** `lib/crud_web/live/item_live/form.ex` (baris 41-45)

```elixir
defp assign_select_options(socket) do
  socket
  |> assign(:category_options, Enum.map(Blog.list_categories(), &{&1.name, &1.id}))
end
```

**Penjelasan:**
- Mengambil daftar category dari database
- Mengubah format menjadi `{label, value}` untuk select options

### 2.3 Fungsi `apply_action/3` (Create Mode)

**File:** `lib/crud_web/live/item_live/form.ex` (baris 59-66)

```elixir
defp apply_action(socket, :new, _params) do
  item = %Item{}

  socket
  |> assign(:page_title, "New Item")
  |> assign(:item, item)
  |> assign(:form, to_form(Product.change_item(item)))
end
```

**Penjelasan:**
- Membuat struct `Item` kosong (`%Item{}`)
- Membuat changeset kosong dari Item
- Mengubah menjadi form yang bisa digunakan di template

### 2.4 Fungsi `Product.change_item/2`

**File:** `lib/crud/product.ex` (baris 105-107)

```elixir
def change_item(%Item{} = item, attrs \\ %{}) do
  Item.changeset(item, attrs)
end
```

**Penjelasan:**
- Fungsi ini hanya wrapper yang memanggil `Item.changeset/2`
- Dengan attrs kosong, ini menghasilkan changeset kosong (tanpa error validasi)

### 2.5 Fungsi `Item.changeset/2`

**File:** `lib/crud/product/item.ex` (baris 13-18)

```elixir
def changeset(item, attrs) do
  item
  |> cast(attrs, [:name, :code, :category_id])
  |> validate_required([:name, :code])
  |> unique_constraint(:code)
end
```

**Penjelasan:**
- `cast/3` - memetakan atribut ke field yang diizinkan
- `validate_required/2` - memastikan field name dan code wajib diisi
- `unique_constraint/2` - memastikan code tidak duplikat di database

**Hasil:** Menghasilkan `Changeset` yang berisi aturan validasi

### 2.6 Template Form Ditampilkan

**File:** `lib/crud_web/live/item_live/form.ex` (baris 17)

```elixir
<.form for={@form} id="item-form" phx-change="validate" phx-submit="save">
  <.input field={@form[:name]} type="text" label="Name" />
  <.input field={@form[:code]} type="text" label="Code" />
  <.input field={@form[:category_id]} type="select" label="Category" options={@category_options} />
  ...
  <.button phx-disable-with="Saving..." variant="primary">Save Item</.button>
</.form>
```

**Penjelasan:**
- Form menggunakan data dari `@form` yang sudah dibuat di `apply_action`
- Tombol "Save Item" memiliki `phx-submit="save"` yang akan mengirim event ke server

---

## Tahap 3: User Submit Form

### 3.1 Handle Event "save"

**File:** `lib/crud_web/live/item_live/form.ex` (baris 74-76)

```elixir
def handle_event("save", %{"item" => item_params}, socket) do
  save_item(socket, socket.assigns.live_action, item_params)
end
```

**Penjelasan:**
- `item_params` adalah map berisi data dari form,пример:
  ```elixir
  %{"name" => "Laptop", "code" => "LPT001", "category_id" => "1"}
  ```

### 3.2 Fungsi `save_item/3`

**File:** `lib/crud_web/live/item_live/form.ex` (baris 91-102)

```elixir
defp save_item(socket, :new, item_params) do
  case Product.create_item(item_params) do
    {:ok, item} ->
      {:noreply,
       socket
       |> put_flash(:info, "Item created successfully")
       |> push_navigate(to: return_path(socket.assigns.return_to, item))}

    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end
```

**Penjelasan:**
- Kondisi `case` memeriksa hasil dari `Product.create_item/1`
- Jika **berhasil** (`{:ok, item}`):
  - Tampilkan pesan sukses
  - Redirect ke halaman list item
- Jika **gagal** (`{:error, changeset}`):
  - Tampilkan form lagi dengan error dari changeset

---

## Tahap 4: Simpan ke Database

### 4.1 Fungsi `Product.create_item/1`

**File:** `lib/crud/product.ex` (baris 56-60)

```elixir
def create_item(attrs) do
  %Item{}
  |> Item.changeset(attrs)
  |> Repo.insert()
end
```

**Penjelasan:**
1. Buat struct Item kosong (`%Item{}`)
2. Panggil `Item.changeset/2` dengan data dari form
3. Panggil `Repo.insert/1` untuk menyimpan ke database

### 4.2 Validasi Ulang dengan `Item.changeset/2`

**File:** `lib/crud/product/item.ex` (baris 13-18)

```elixir
def changeset(item, attrs) do
  item
  |> cast(attrs, [:name, :code, :category_id])
  |> validate_required([:name, :code])
  |> unique_constraint(:code)
end
```

**Penjelasan:**
- Sama seperti tahap 2.5, tapi sekarang attrs berisi data dari form
- Validasi dilakukan lagi di level database

### 4.3 `Repo.insert/1` (Ecto)

**Penjelasan:**
- Ecto membuat query `INSERT INTO items ...` dan eksekusi ke database
- Jika berhasil: return `{:ok, %Item{id: 1, ...}}`
- Jika gagal: return `{:error, %Ecto.Changeset{...}}`

---

## Tahap 5: Response dan Redirect

Setelah `Repo.insert/1` berhasil:

1. `save_item/3` menerima `{:ok, item}`
2. Menambahkan flash message: `"Item created successfully"`
3. `push_navigate` mengarahkan ke `/items`
4. User melihat halaman list item dengan data baru

---

## Ringkasan (Tabel Singkat)

| Tahap | File | Fungsi | Keterangan |
|-------|------|--------|------------|
| 1 | `index.ex` | User klik tombol `navigate` | Pergi ke `/items/new` |
| 2 | `form.ex` | `mount/3` | Inisialisasi LiveView |
| 2 | `form.ex` | `apply_action(..., :new, ...)` | Siapkan form kosong |
| 2 | `product.ex` | `change_item/2` | Buat changeset kosong |
| 2 | `item.ex` | `Item.changeset/2` | Definisikan validasi |
| 3 | `form.ex` | `handle_event("save", ...)` | Terima data dari form |
| 3 | `form.ex` | `save_item(..., :new, ...)` | Proses berdasarkan action |
| 4 | `product.ex` | `create_item/1` | Proses pembuatan item |
| 4 | `item.ex` | `Item.changeset/2` | Validasi data |
| 4 | `repo.ex` | `Repo.insert/1` | Simpan ke database |
| 5 | `form.ex` | `push_navigate/2` | Redirect ke list |

---

## Catatan Penting

1. **Validasi terjadi 2x:**
   - Pertama di `handle_event("validate", ...)` - validasi real-time saat user mengetik
   - Kedua di `Item.changeset/2` yang dipanggil dari `create_item/1`

2. **Phoenix Component:**
   - `<.form>` adalah komponen dari `core_components.ex`
   - `<.input>` adalah komponen form dari `core_components.ex`

3. **LiveAction:**
   - `:new` menandakan mode create
   - `:edit` menandakan mode update
   - Ditentukan oleh router saat mount