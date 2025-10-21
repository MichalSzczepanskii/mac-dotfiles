# ~/.zsh_functions/nx_angular_commands.sh

custom_command_runner() {
  local base_command="$1"
  local func_name="$2"
  eval "
    $func_name() {
      if [ -z \"\$1\" ]; then
        echo \"Usage: $func_name <name> [flags]\"
        return 1
      fi
      local arg=\"\$1\"
      shift
      $base_command \"\$arg/\$arg\" \"\$@\"
    }
  "
}

custom_command_runner "npx nx g @nx/angular:component" agc
