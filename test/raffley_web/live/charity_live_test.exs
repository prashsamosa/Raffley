defmodule RaffleyWeb.CharityLiveTest do
  use RaffleyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Raffley.CharitiesFixtures
  import Raffley.AccountsFixtures

  @create_attrs %{name: "some name", slug: "some slug"}
  @update_attrs %{name: "some updated name", slug: "some updated slug"}
  @invalid_attrs %{name: nil, slug: nil}

  defp create_charity(_) do
    charity = charity_fixture()
    %{charity: charity}
  end

  describe "Index" do
    setup %{conn: conn} do
      password = valid_user_password()
      user = admin_user_fixture(%{password: password})
      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    setup [:create_charity]

    test "lists all charities", %{conn: conn, charity: charity} do
      {:ok, _index_live, html} = live(conn, ~p"/charities")

      assert html =~ "Listing Charities"
      assert html =~ charity.name
    end

    test "saves new charity", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/charities")

      assert {:ok, form_live, _} =
               index_live
               |> element("button", "New Charity")
               |> render_click()
               |> follow_redirect(conn, ~p"/charities/new")

      assert render(form_live) =~ "New Charity"

      assert form_live
             |> form("#charity-form", charity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#charity-form", charity: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/charities")

      html = render(index_live)
      assert html =~ "Charity created successfully"
      assert html =~ "some name"
    end

    test "updates charity in listing", %{conn: conn, charity: charity} do
      {:ok, index_live, _html} = live(conn, ~p"/charities")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#charities-#{charity.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/charities/#{charity}/edit")

      assert render(form_live) =~ "Edit Charity"

      assert form_live
             |> form("#charity-form", charity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#charity-form", charity: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/charities")

      html = render(index_live)
      assert html =~ "Charity updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes charity in listing", %{conn: conn, charity: charity} do
      {:ok, index_live, _html} = live(conn, ~p"/charities")

      assert index_live |> element("#charities-#{charity.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#charities-#{charity.id}")
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/charities")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "redirects if logged-in user is not an admin" do
      password = valid_user_password()
      user = user_fixture(%{password: password})

      conn =
        build_conn()
        |> log_in_user(user)

      {:error, redirect} = live(conn, ~p"/charities")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/"
      assert %{"error" => "Only admins allowed!"} = flash
    end
  end

  describe "Show" do
    setup %{conn: conn} do
      password = valid_user_password()
      user = admin_user_fixture(%{password: password})
      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    setup [:create_charity]

    test "displays charity", %{conn: conn, charity: charity} do
      {:ok, _show_live, html} = live(conn, ~p"/charities/#{charity}")

      assert html =~ "Show Charity"
      assert html =~ charity.name
    end

    test "updates charity and returns to show", %{conn: conn, charity: charity} do
      {:ok, show_live, _html} = live(conn, ~p"/charities/#{charity}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/charities/#{charity}/edit?return_to=show")

      assert render(form_live) =~ "Edit Charity"

      assert form_live
             |> form("#charity-form", charity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#charity-form", charity: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/charities/#{charity}")

      html = render(show_live)
      assert html =~ "Charity updated successfully"
      assert html =~ "some updated name"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/charities")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "redirects if logged-in user is not an admin" do
      password = valid_user_password()
      user = user_fixture(%{password: password})

      conn =
        build_conn()
        |> log_in_user(user)

      {:error, redirect} = live(conn, ~p"/charities")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/"
      assert %{"error" => "Only admins allowed!"} = flash
    end
  end
end
