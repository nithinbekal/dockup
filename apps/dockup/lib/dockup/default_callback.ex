defmodule Dockup.DefaultCallback do
  require Logger

  def lambda do
    fn event, payload ->
      Logger.info "#{event} event was triggered with payload #{inspect payload}"
    end
  end
end
