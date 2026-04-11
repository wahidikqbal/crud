# Alur CRUD Blog - Post

Dokumen ini menjelaskan alur lengkap operasi Create, Edit, Show, dan Delete pada Post.

---

## CREATE (Membuat Post Baru)

### Diagram Alur

```
User klik "New Post" → /posts/new
        ↓
PostLive.Form mount (live_action: :new)
        ↓
apply_action(..., :new, ...) → %Post{} kosong
        ↓
Blog.change_post(post) → changeset kosong
        ↓
Form ditampilkan
        ↓
User klik "Save Post"
        ↓
handle_event("save", %{"post" => params})
        ↓
save_post(..., :new, params)
        ↓
Blog.create_post(params)
        ↓
Post.changeset + put_assoc(:tags)
        ↓
Repo.insert → DB
        ↓
Redirect ke /posts
```

### Urutan Detail

| Tahap | File | Fungsi | Keterangan |
|-------|------|--------|------------|
| 1 | `index.ex:13` | User klik `navigate` ke `/posts/new` | Tombol "New Post" |
| 2 | `form.ex:33` | `mount/3` dipanggil | Inisialisasi LiveView |
| 3 | `form.ex:57` | `apply_action(..., :new, ...)` | Membuat `%Post{}` kosong |
| 4 | `form.ex:67` | `assign_select_options()` | Ambil category & tag |
| 5 | `blog.ex:137` | `change_post/2` | Buat changeset |
| 6 | `post.ex:16` | `Post.changeset/2` | Validasi field |
| 7 | Template | Form ditampilkan | Input: title, body, category, tags |
| 8 | `form.ex:79` | `handle_event("save", ...)` | Terima params |
| 9 | `form.ex:98` | `save_post(..., :new, ...)` | Pilih action :new |
| 10 | `blog.ex:86` | `create_post/1` | Proses pembuatan |
| 11 | `post.ex:16` | `Post.changeset/2` | Validasi data |
| 12 | `blog.ex:50` | `tags_from_attrs/1` | Parse tag_ids |
| 13 | `blog.ex:89` | `put_assoc(:tags, ...)` | Tambahkan asosiasi tags |
| 14 | Ecto | `Repo.insert/1` | Simpan ke DB |
| 15 | `form.ex:100` | `push_navigate` | Redirect ke /posts |

---

## EDIT (Mengubah Post)

### Diagram Alur

```
User klik "Edit" → /posts/:id/edit
        ↓
PostLive.Form mount (live_action: :edit)
        ↓
apply_action(..., :edit, id)
        ↓
Blog.get_post!(id) → preload category & tags
        ↓
Blog.change_post(post) → changeset dengan data
        ↓
Form ditampilkan (data terisi)
        ↓
User ubah data & klik "Save Post"
        ↓
handle_event("save", %{"post" => params})
        ↓
save_post(..., :edit, params)
        ↓
Blog.update_post(post, params)
        ↓
Post.changeset + put_assoc(:tags)
        ↓
Repo.update → DB
        ↓
Redirect sesuai return_to
```

### Urutan Detail

| Tahap | File | Fungsi | Keterangan |
|-------|------|--------|------------|
| 1 | `index.ex:46` | User klik `navigate` ke `/posts/:id/edit` | Tombol "Edit" |
| 2 | `form.ex:33` | `mount/3` dipanggil | Inisialisasi LiveView |
| 3 | `form.ex:47` | `apply_action(..., :edit, %{"id" => id})` | Ambil ID dari params |
| 4 | `blog.ex:42` | `get_post!(id)` | Ambil post dari DB |
| 5 | `blog.ex:44` | `Repo.preload([:category, :tags])` | Load relasi |
| 6 | `blog.ex:137` | `change_post(post)` | Buat changeset |
| 7 | `blog.ex:144` | `with_tags_ids/1` | Convert tags ke tag_ids |
| 8 | `post.ex:16` | `Post.changeset/2` | Validasi dengan data |
| 9 | Template | Form ditampilkan | Input terisi data lama |
| 10 | `form.ex:74` | `handle_event("validate", ...)` | Validasi real-time |
| 11 | `form.ex:79` | `handle_event("save", ...)` | Submit perubahan |
| 12 | `form.ex:84` | `save_post(..., :edit, ...)` | Pilih action :edit |
| 13 | `blog.ex:105` | `update_post/2` | Proses update |
| 14 | `post.ex:16` | `Post.changeset/2` | Validasi data baru |
| 15 | `blog.ex:50` | `tags_from_attrs/1` | Parse tag_ids baru |
| 16 | `blog.ex:108` | `put_assoc(:tags, ...)` | Update asosiasi tags |
| 17 | Ecto | `Repo.update/1` | Update di DB |
| 18 | `form.ex:86` | `push_navigate` | Redirect (ke show atau index) |

---

## SHOW (Melihat Detail Post)

### Diagram Alur

```
User klik row/Show → /posts/:id
        ↓
PostLive.Show mount(id)
        ↓
Blog.get_post!(id) → preload category & tags
        ↓
Tampilkan detail post
```

### Urutan Detail

| Tahap | File | Fungsi | Keterangan |
|-------|------|--------|------------|
| 1 | `index.ex:44` | User klik `navigate` ke `/posts/:id` | Klik baris atau "Show" |
| 2 | `show.ex:32` | `mount(%{"id" => id}, ...)` | Ambil ID dari params |
| 3 | `blog.ex:42` | `get_post!(id)` | Ambil post dari DB |
| 4 | `blog.ex:44` | `Repo.preload([:category, :tags])` | Load relasi |
| 5 | Template | Tampilkan detail | Title, Body, Category, Tags |

---

## DELETE (Menghapus Post)

### Diagram Alur

```
User klik "Delete" → JS.push("delete")
        ↓
handle_event("delete", %{"id": id})
        ↓
Blog.get_post!(id)
        ↓
Blog.delete_post(post)
        ↓
Repo.delete → DB
        ↓
stream_delete(:posts, post)
```

### Urutan Detail

| Tahap | File | Fungsi | Keterangan |
|-------|------|--------|------------|
| 1 | `index.ex:48` | User klik link dengan `phx-click` | Tombol "Delete" |
| 2 | `index.ex:50` | `JS.push("delete", value: %{id: post.id})` | Kirim event ke server |
| 3 | `index.ex:70` | `handle_event("delete", %{"id" => id}, ...)` | Terima event |
| 4 | `blog.ex:42` | `get_post!(id)` | Ambil post yang akan dihapus |
| 5 | `blog.ex:124` | `delete_post(post)` | Proses hapus |
| 6 | Ecto | `Repo.delete/1` | Hapus dari DB |
| 7 | `index.ex:74` | `stream_delete(:posts, post)` | Hapus dari UI |
| 8 | `index.ex:75` | `put_flash(:info, ...)` | Tampilkan pesan sukses |

---

## Ringkasan File dan Fungsi

### LiveView (UI Layer)

| File | Fungsi | Operasi |
|------|--------|---------|
| `lib/crud_web/live/post_live/index.ex` | `mount/3` | Load semua post |
| `lib/crud_web/live/post_live/index.ex` | `handle_event("delete", ...)` | Hapus post |
| `lib/crud_web/live/post_live/form.ex` | `mount/3` | Setup form (new/edit) |
| `lib/crud_web/live/post_live/form.ex` | `apply_action/3` | Siapkan data untuk form |
| `lib/crud_web/live/post_live/form.ex` | `handle_event("validate", ...)` | Validasi real-time |
| `lib/crud_web/live/post_live/form.ex` | `handle_event("save", ...)` | Submit form |
| `lib/crud_web/live/post_live/form.ex` | `save_post/3` | Proses save (new/edit) |
| `lib/crud_web/live/post_live/show.ex` | `mount/3` | Ambil satu post |

### Context (Business Logic)

| File | Fungsi | Keterangan |
|------|--------|------------|
| `lib/crud/blog.ex` | `list_posts/0` | Ambil semua post + preload |
| `lib/crud/blog.ex` | `get_post!/1` | Ambil post by ID + preload |
| `lib/crud/blog.ex` | `create_post/1` | Buat post baru |
| `lib/crud/blog.ex` | `update_post/2` | Update post |
| `lib/crud/blog.ex` | `delete_post/1` | Hapus post |
| `lib/crud/blog.ex` | `change_post/2` | Buat changeset |
| `lib/crud/blog.ex` | `tags_from_attrs/1` | Parse tag_ids |

### Schema (Data Layer)

| File | Fungsi | Keterangan |
|------|--------|------------|
| `lib/crud/blog/post.ex` | `Post.changeset/2` | Validasi & transformasi |
| `lib/crud/blog/post.ex` | Schema | Definisi tabel dan relasi |

---

## Catatan Penting

1. **Preload Relasi:** 
   - `list_posts/0` dan `get_post!/1` preload `:category` dan `:tags`
   - Di form edit, `with_tags_ids/1` mengconvert list tags ke field virtual `tag_ids`

2. **Validasi Real-time:**
   - `handle_event("validate", ...)` dipanggil saat user mengetik (bukan saat submit)
   - Menggunakan `phx-change="validate"` di form

3. **Many-to-Many:**
   - Post memiliki relasi many-to-many dengan Tags melalui table `posts_tags`
   - `put_assoc(:tags, ...)` menangani penyimpanan relasi

4. **Return Path:**
   - Di form, ada parameter `return_to` untuk menentukan redirect setelah save
   - Bisa ke `/posts` (index) atau `/posts/:id` (show)