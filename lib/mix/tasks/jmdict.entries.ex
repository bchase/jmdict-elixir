defmodule Mix.Tasks.JMDict.Entries do
  use Mix.Task

  @shortdoc "calls the passed Mod.fun, passing a stream of entries"

  # @moduledoc """
  # """

  def run([mod_fun_str]) do
    print_msg mod_fun_str

    {mod, fun_atom} = get_mod_and_fun_atom_from_str(mod_fun_str)

    apply mod, fun_atom, [JMDict.entries_stream]
  end

  defp get_mod_and_fun_atom_from_str(mod_fun_str) do
    [_, mod_str, fun_str] = Regex.run ~r{(.+)\.(\w+)}, mod_fun_str

    mod      = Module.concat [mod_str]
    fun_atom = String.to_atom fun_str

    {mod, fun_atom}
  end

  defp print_msg(mod_fun_str) do
    Mix.shell.info ">>> calling: #{mod_fun_str}(JMDict.entries_stream)"
  end
end
