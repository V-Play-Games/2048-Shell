# Cell structure: ijvMm
# i -> row
# j -> column
# v -> value
# M -> moved (0 for no, 1 for yes)
# m -> modified (0 for no, 1 for yes)

cell_value_formatted=("    " "  2 " "  4 " "  8 " " 16 " " 32 " " 64 " "128 " "256 " "512 " "1024" "2048")
spawns=(1 1 1 1 2)
board=()

game2048() {
  help="Commands:
U to swipe up
D to swipe down
L to swipe left
R to swipe right
E to end the game
H for help"
  echo -n "Enter size of the board (default 4): "
  read -r size
  echo "You chose a board of size $size x $size"
  for ((i = 0; i < size; i++)); do
    for ((j = 0; j < size; j++)); do
      set_cell i j "$i$j$((0))$((0))$((0))"
    done
  done

  spawn
  spawn
  display_board
}

spawn() {
  local value=${spawns[$((RANDOM % ${#spawns[@]}))]}
  local empty_cells=()
  for ((i = 0; i < size; i++)); do
    for ((j = 0; j < size; j++)); do
      if [[ $(get_cell_value "$i" "$j") == 0 ]]; then
        empty_cells+=("$i $j")
      fi
    done
  done
  if [[ ${#empty_cells[@]} -eq 0 ]]; then
      return
  fi
  local random_index=$((RANDOM % ${#empty_cells[@]}))
  # shellcheck disable=SC2086
  update_cell_value ${empty_cells[$random_index]} "$value"
}

get_index() {
  local row=$1
  local col=$2
  echo $((row * size + col))
}

set_cell() {
  local row=$1
  local col=$2
  local value=$3
  board[$(get_index "$row" "$col")]="$value"
}

get_cell() {
  local row=$1
  local col=$2
  echo "${board[$(get_index "$row" "$col")]}"
}

get_cell_value() {
  local row=$1
  local col=$2

  local cell_data
  cell_data=$(get_cell "$row" "$col")

  local value=${cell_data:2:1}
  echo "$value"
}

update_cell_value() {
  local row=$1
  local col=$2
  local new_value=$3

  local cell_data
  cell_data=$(get_cell "$row" "$col")

  local i=${cell_data:0:1}
  local j=${cell_data:1:1}

  local moved=${cell_data:3:1}
  local modified=${cell_data:4:1}

  set_cell "$row" "$col" "$i$j$new_value$moved$modified"
}

display_board() {
  boundary="+------+------+------+------+"
  echo "$boundary"
  for ((i = 0; i < size; i++)); do
    echo -n "| "
    for ((j = 0; j < size; j++)); do
      local value
      value=$(get_cell_value $i $j)
      echo -n "${cell_value_formatted[$value]} | "
    done
    echo -e ""
  done
  echo "$boundary"
}

game2048
