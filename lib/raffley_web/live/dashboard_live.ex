defmodule RaffleyWeb.DashboardLive do
  use RaffleyWeb, :live_view

  def mount(_params, _session, socket) do
    data = Raffley.Admin.ticket_tallies()

    {:ok, assign(socket, :data, data)}
  end

  def render(assigns) do
    ~H"""
    <.header>
      Dashboard
    </.header>
    <.table id="report" rows={@data}>
      <:col :let={item} label="Prize">
        {item[:prize]}
      </:col>

      <:col :let={item} label="Charity">
        {item[:charity]}
      </:col>

      <:col :let={item} label="Ticket Count">
        {item[:ticket_count]}
      </:col>

      <:col :let={item} label="Ticket Total">
        ${item[:ticket_total]}
      </:col>
    </.table>
    """
  end
end
