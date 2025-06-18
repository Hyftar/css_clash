defmodule CssClashWeb.TargetLive.Form do
  use CssClashWeb, :live_view

  alias CssClash.Targets
  alias CssClash.Targets.Target

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
    target = Targets.get_target!(id)

    socket
    |> assign(:page_title, "Edit Target")
    |> assign(:target, target)
    |> assign(:form, to_form(Targets.change_target(target)))
  end

  defp apply_action(socket, :new, _params) do
    target = %Target{}

    socket
    |> assign(:page_title, "New Target")
    |> assign(:target, target)
    |> assign(:form, to_form(Targets.change_target(target)))
  end

  defp save_target(socket, :edit, target_params) do
    case Targets.update_target(socket.assigns.target, target_params) do
      {:ok, target} ->
        {:noreply,
         socket
         |> put_flash(:info, "Target updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, target))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_target(socket, :new, target_params) do
    case Targets.create_target(target_params) do
      {:ok, target} ->
        {:noreply,
         socket
         |> put_flash(:info, "Target created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, target))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _target), do: ~p"/targets"
  defp return_path("show", target), do: ~p"/targets/#{target}"

  @impl true
  def handle_event("validate", %{"target" => target_params}, socket) do
    changeset = Targets.change_target(socket.assigns.target, target_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"target" => target_params}, socket) do
    save_target(socket, socket.assigns.live_action, target_params)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage target records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="target-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:image_data]} type="text" label="Image data" />
        <.input
          field={@form[:colors]}
          type="select"
          multiple
          label="Colors"
          options={[{"Option 1", "option1"}, {"Option 2", "option2"}]}
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Target</.button>
          <.button navigate={return_path(@return_to, @target)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end
end
