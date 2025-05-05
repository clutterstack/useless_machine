defmodule UselessMachineWeb.CheckMachineEdgeCasesTest do
  use UselessMachineWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  # One-shot from Claude. Haven't tried it
  # https://claude.ai/chat/9c984b78-0350-4f75-b5cb-e77e2743dbaf

  alias UselessMachineWeb.CheckMachine

  describe "params availability in different mount scenarios" do
    setup do
      # Set a known machine ID
      System.put_env("FLY_MACHINE_ID", "test-machine-123")

      on_exit(fn ->
        System.delete_env("FLY_MACHINE_ID")
      end)

      :ok
    end

    test "fresh HTTP request has params", %{conn: conn} do
      # Fresh HTTP request should always have params from the route
      {:ok, view, _html} = live(conn, "/test-machine-123")

      # The LiveView should mount successfully
      assert render(view) =~ "This is Fly Machine test-machine-123"
    end

    test "websocket reconnection might not have route params", %{conn: conn} do
      # Start with a successful mount
      {:ok, view, _html} = live(conn, "/test-machine-123")

      # Simulate a disconnect/reconnect scenario
      # In practice, the reconnect might happen without the route params

      # The extract_path_from_connect_params function attempts to handle this
      # by looking at the _live_referer in connect_params
    end

    test "navigation within LiveView preserves machine context", %{conn: conn} do
      # Mount the LiveView
      {:ok, view, _html} = live(conn, "/test-machine-123")

      # If you had navigation within the LiveView (which you don't currently),
      # params might get lost during patch operations

      # Example of what might happen with live_patch:
      # live_patch(view, "/test-machine-123/some_action")
      # This could potentially lose the mach_id param
    end
  end

  describe "failure modes" do
    test "what happens when CheckMachine redirects but RouteHandler already acted", %{conn: conn} do
      # This tests the interaction between RouteHandler and CheckMachine
      System.put_env("FLY_MACHINE_ID", "test-machine-123")

      # Try to access wrong machine
      # RouteHandler should catch this first and send 301 with fly-replay header
      conn = get(conn, "/wrong-machine-456")

      assert conn.status == 301
      assert conn.halted

      # CheckMachine never gets called because RouteHandler halted the conn
    end

    test "direct LiveView mount without going through router", %{conn: conn} do
      # This is an edge case - if somehow the LiveView is mounted directly
      # without going through the router (shouldn't happen in normal usage)
      System.put_env("FLY_MACHINE_ID", "test-machine-123")

      # If you could somehow bypass the router and mount directly,
      # CheckMachine would still need the mach_id param

      # This is mostly theoretical as Phoenix routes LiveView through the router
    end
  end

  describe "extract_path_from_connect_params helper" do
    # Since extract_path_from_connect_params is private, you might want to
    # either make it public for testing or test it indirectly

    test "extracts machine ID from referer URL" do
      # Create a mock socket with connect_params
      socket = %Phoenix.LiveView.Socket{
        private: %{
          connect_params: %{
            "_live_referer" => "https://useless-machine.fly.dev/test-machine-123"
          }
        },
        assigns: %{}
      }

      # You'd need to expose this function or test it differently
      # path = CheckMachine.extract_path_from_connect_params(socket)
      # assert path == ["test-machine-123"]
    end

    test "handles missing connect_params gracefully" do
      socket = %Phoenix.LiveView.Socket{
        private: %{},
        assigns: %{}
      }

      # Should return empty list when no connect_params
      # path = CheckMachine.extract_path_from_connect_params(socket)
      # assert path == []
    end
  end
end
