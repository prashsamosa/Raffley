defmodule RaffleyWeb.CharityLive.Form do
  use RaffleyWeb, :live_view

  alias Raffley.Charities
  alias Raffley.Charities.Charity

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
      <:subtitle>Use this form to manage charity records in your database.</:subtitle>
    </.header>

    <.simple_form for={@form} id="charity-form" phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} type="text" label="Name" />
      <.input field={@form[:slug]} type="text" label="Slug" />
      <:actions>
        <.button phx-disable-with="Saving...">Save Charity</.button>
      </:actions>
    </.simple_form>

    <.back navigate={return_path(@return_to, @charity)}>Back</.back>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    charity = Charities.get_charity!(id)

    socket
    |> assign(:page_title, "Edit Charity")
    |> assign(:charity, charity)
    |> assign(:form, to_form(Charities.change_charity(charity)))
  end

  defp apply_action(socket, :new, _params) do
    charity = %Charity{}

    socket
    |> assign(:page_title, "New Charity")
    |> assign(:charity, charity)
    |> assign(:form, to_form(Charities.change_charity(charity)))
  end

  @impl true
  def handle_event("validate", %{"charity" => charity_params}, socket) do
    changeset = Charities.change_charity(socket.assigns.charity, charity_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"charity" => charity_params}, socket) do
    save_charity(socket, socket.assigns.live_action, charity_params)
  end

  defp save_charity(socket, :edit, charity_params) do
    case Charities.update_charity(socket.assigns.charity, charity_params) do
      {:ok, charity} ->
        {:noreply,
         socket
         |> put_flash(:info, "Charity updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, charity))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_charity(socket, :new, charity_params) do
    case Charities.create_charity(charity_params) do
      {:ok, charity} ->
        {:noreply,
         socket
         |> put_flash(:info, "Charity created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, charity))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _charity), do: ~p"/charities"
  defp return_path("show", charity), do: ~p"/charities/#{charity}"
end
