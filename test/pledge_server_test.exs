defmodule PledgeServertest do
  use ExUnit.Case, async: true
  alias Servy.PledgeServer

  setup do
    pid = PledgeServer.start()

    on_exit fn ->
      Process.exit(pid, :kill)
    end
  end

  test "Caches the three most recent pledges" do
    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.create_pledge("daisy", 40)
    PledgeServer.create_pledge("grace", 50)

    expected_pledges = [
      {"grace", 50},
      {"daisy", 40},
      {"curly", 30}
    ]

    assert PledgeServer.recent_pledges() == expected_pledges
  end

  test "Can calculate the total amount pledged" do
    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.create_pledge("daisy", 40)
    PledgeServer.create_pledge("grace", 50)

    assert PledgeServer.total_pledged() == 120
  end
end
