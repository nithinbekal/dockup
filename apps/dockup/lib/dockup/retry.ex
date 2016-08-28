defmodule Dockup.Retry do
  require Logger

  # Credit for this code goes to safwank/ElixirRetry library

  @lint false
  defmacro retry({:in, _, [retries, sleep]}, do: block) do
    quote do
      run = fn(attempt, self) ->
        if attempt <= unquote(retries) do
          try do
            unquote(block)
          rescue
            e ->
              Logger.info "Attempt #{attempt} failed because of error: #{inspect e}"
              :timer.sleep(unquote(sleep))
              self.(attempt + 1, self)
          end
        else
          raise DockupException, "Reached max number of retries"
        end
      end

      run.(1, run)
    end
  end
end
