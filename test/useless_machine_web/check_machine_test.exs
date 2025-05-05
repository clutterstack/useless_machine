defmodule UselessMachineWeb.CheckMachineTest do
  use UselessMachineWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias UselessMachineWeb.CheckMachine

  # one-shot from Claude. Haven't tried it.
  # https://claude.ai/chat/9c984b78-0350-4f75-b5cb-e77e2743dbaf

  setup do
    # Store original env var if exists
    original_machine_id = System.get_env("FLY_MACHINE_ID")

    on_exit(fn ->
      # Restore original env var after each test
      if original_machine_id do
        System.put_env("FLY_MACHINE_ID", original_machine_id)
      else
        System.delete_env("FLY_MACHINE_ID")
      end
    end)

    :ok
  end

  describe "on_mount/4" do
    test "continues mount when machine ID matches", %{conn: conn} do
      # Set up the environment
      System.put_env("FLY_MACHINE_ID", "test-machine-123")

      # Mock socket structure
      socket = %Phoenix.LiveView.Socket{
        private: %{},
        assigns: %{}
      }

      params = %{"mach_id" => "test-machine-123"}

      # Call the on_mount callback
      result = CheckMachine.on_mount(:default, params, %{}, socket)

      assert {:cont, _socket} = result
    end

    test "halts and redirects when machine ID doesn't match", %{conn: conn} do
      # Set up the environment
      System.put_env("FLY_MACHINE_ID", "test-machine-123")

      # Mock socket structure
      socket = %Phoenix.LiveView.Socket{
        private: %{},
        assigns: %{},
        redirected: nil
      }

      params = %{"mach_id" => "wrong-machine-456"}

      # Call the on_mount callback
      result = CheckMachine.on_mount(:default, params, %{}, socket)

      assert {:halt, socket} = result
      # Check that the socket has been redirected
      assert socket.redirected != nil
      assert socket.redirected.to == "/wrong-machine-456"
    end

    test "handles nil machine ID in environment", %{conn: conn} do
      # Ensure FLY_MACHINE_ID is not set
      System.delete_env("FLY_MACHINE_ID")

      socket = %Phoenix.LiveView.Socket{
        private: %{},
        assigns: %{}
      }

      params = %{"mach_id" => "any-machine-123"}

      # Call the on_mount callback
      result = CheckMachine.on_mount(:default, params, %{}, socket)

      # Since nil won't match "any-machine-123", it should redirect
      assert {:halt, socket} = result
      assert socket.redirected != nil
      assert socket.redirected.to == "/any-machine-123"
    end
  end

  describe "integration with LiveView mounting" do
    test "LiveView mounts successfully with correct machine ID", %{conn: conn} do
      System.put_env("FLY_MACHINE_ID", "test-machine-123")

      # This would normally go through your router's RouteHandler plug first
      {:ok, _view, html} = live(conn, "/test-machine-123")

      assert html =~ "You started a Useless Machine"
      assert html =~ "test-machine-123"
    end

    test "RouteHandler redirects before LiveView when machine ID mismatches", %{conn: conn} do
      System.put_env("FLY_MACHINE_ID", "test-machine-123")

      # Try to access wrong machine - RouteHandler should intercept
      conn = get(conn, "/wrong-machine-456")

      assert conn.status == 301
      assert get_resp_header(conn, "fly-replay") == ["instance=wrong-machine-456"]
    end
  end

  describe "reconnection scenarios" do
    @tag :capture_log
    test "LiveView reconnection without route params", %{conn: conn} do
      System.put_env("FLY_MACHINE_ID", "test-machine-123")

      # Start with successful mount
      {:ok, view, _html} = live(conn, "/test-machine-123")

      # Simulate a reconnection attempt
      # In a real reconnection, params might be missing
      # This is where extract_path_from_connect_params would be used

      # Since we can't easily simulate a real websocket reconnection in tests,
      # we'll test the extraction function directly
      socket_with_referer = %Phoenix.LiveView.Socket{
        private: %{
          connect_params: %{
            "_live_referer" => "https://example.com/test-machine-123"
          }
        },
        assigns: %{}
      }

      # The private function would need to be exposed for testing or tested differently
      # This is where your concern about missing params comes in
    end
  end

  describe "edge cases and failure scenarios" do
    test "handles missing mach_id in params", %{conn: conn} do
      System.put_env("FLY_MACHINE_ID", "test-machine-123")

      socket = %Phoenix.LiveView.Socket{
        private: %{},
        assigns: %{}
      }

      # Missing mach_id in params
      params = %{}

      # This will likely cause a pattern match error in your current implementation
      # You might want to handle this case
      assert_raise FunctionClauseError, fn ->
        CheckMachine.on_mount(:default, params, %{}, socket)
      end
    end
  end
end
