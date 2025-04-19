defmodule RaffleyWeb.AdminRaffleLive.Form do
  use RaffleyWeb, :live_view

  alias Raffley.Admin
  alias Raffley.Raffles.Raffle
  alias Raffley.Charities

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:charity_options, Charities.charity_names_and_ids())
      |> apply_action(socket.assigns.live_action, params)
      |> allow_upload(:image,
        accept: ~w(.png .jpeg .jpg),
        max_entries: 1,
        max_file_size: 10_000_000
      )

    {:ok, socket}
  end

  defp apply_action(socket, :new, _params) do
    raffle = %Raffle{}

    changeset = Admin.change_raffle(raffle)

    socket
    |> assign(:page_title, "New Raffle")
    |> assign(:form, to_form(changeset))
    |> assign(:raffle, raffle)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    raffle = Admin.get_raffle!(id)

    changeset = Admin.change_raffle(raffle)

    socket
    |> assign(:page_title, "Edit Raffle")
    |> assign(:form, to_form(changeset))
    |> assign(:raffle, raffle)
  end

  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>
    <.simple_form for={@form} id="raffle-form" phx-submit="save" phx-change="validate">
      <.input field={@form[:prize]} label="Prize" />

      <.input field={@form[:description]} type="textarea" label="Description" phx-debounce="blur" />

      <.input field={@form[:ticket_price]} type="number" label="Ticket price" />

      <.input
        field={@form[:status]}
        type="select"
        label="Status"
        prompt="Choose a status"
        options={[:upcoming, :open, :closed]}
      />

      <.input
        field={@form[:charity_id]}
        type="select"
        label="Charity"
        prompt="Choose a charity"
        options={@charity_options}
      />

      <div class="thumbnail">
        <.input field={@form[:image_path]} label="Image Path" />
        <img src={@raffle.image_path} />
      </div>

      <.label>
        Add {@uploads.image.max_entries} image
        (max {trunc(@uploads.image.max_file_size / 1_000_000)} MB)
      </.label>

      <div class="drop" phx-drop-target={@uploads.image.ref}>
        <.live_file_input upload={@uploads.image} />
        <span>or drag and drop here</span>
      </div>

      <div :for={entry <- @uploads.image.entries} class="entry">
        <.live_img_preview entry={entry} />

        <div class="progress">
          <div class="value">
            {entry.progress}%
          </div>
          <div class="bar">
            <span style={"width: #{entry.progress}%"}></span>
          </div>
          <.error :for={err <- upload_errors(@uploads.image, entry)}>
            {Phoenix.Naming.humanize(err)}
          </.error>
        </div>

        <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref}>
          &times;
        </button>
      </div>

      <:actions>
        <.button phx-disable-with="Saving...">Save Raffle</.button>
      </:actions>
    </.simple_form>

    <.back navigate={~p"/admin/raffles"}>
      Back
    </.back>
    """
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  def handle_event("validate", %{"raffle" => raffle_params}, socket) do
    changeset = Admin.change_raffle(socket.assigns.raffle, raffle_params)
    socket = assign(socket, :form, to_form(changeset, action: :validate))
    {:noreply, socket}
  end

  def handle_event("save", %{"raffle" => raffle_params}, socket) do
    uploads_dir = Application.app_dir(:raffley, "priv/static/uploads")
    File.mkdir_p!(uploads_dir)

    uploaded_files =
      consume_uploaded_entries(socket, :image, fn meta, entry ->
        dest = Path.join(uploads_dir, "#{entry.uuid}-#{entry.client_name}")

        # 1. Copy temp file to priv/static/uploads/xxx.jpg

        File.cp!(meta.path, dest)

        # 2. Generate a URL path: /uploads/xxx.jpg

        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    # 3. Assign URL path to image_path, if necessary

    raffle_params =
      case uploaded_files do
        [path] -> Map.put(raffle_params, "image_path", path)
        [] -> raffle_params
      end

    save_raffle(socket, socket.assigns.live_action, raffle_params)
  end

  defp save_raffle(socket, :new, raffle_params) do
    case Admin.create_raffle(raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle created successfully!")
          |> push_navigate(to: ~p"/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end

  defp save_raffle(socket, :edit, raffle_params) do
    case Admin.update_raffle(socket.assigns.raffle, raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle updated successfully!")
          |> push_navigate(to: ~p"/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end
end
