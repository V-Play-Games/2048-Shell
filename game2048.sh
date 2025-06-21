help="Commands:
U to swipe up
D to swipe down
L to swipe left
R to swipe right
Q to quit the game
H for help"

# Move Enum
# 0 -> Up
# 1 -> Down
# 2 -> Left
# 3 -> Right

move_rc_changes=(
  01 # Up
  21 # Down
  10 # Left
  12 # Right
)
# 0 -> -1
# 1 -> 0
# 2 -> +1

# Cell structure: iivMm
# i -> row
# i -> column
# v -> value
# M -> moved (0 for no, 1 for yes)
# m -> modified (0 for no, 1 for yes)

cell_value_formatted=("    " "  2 " "  4 " "  8 " " 16 " " 32 " " 64 " "128 " "256 " "512 " "1024" "2048")
spawns=(1 1 1 1 2)
win=0
lose=0
score=0
board=()

end() {
  echo "Thanks for playing!"
}

help() {
  echo "$help"
}

menu() {
  read -r -p "Select an option: " choice
  case $choice in
    u|U) up ;;
    d|D) down ;;
    l|L) left ;;
    r|R) right ;;
    q|Q) end ;;
    h|H) help; menu ;;
    *) echo "Invalid option!"; menu ;;
  esac
}

game2048() {
  read -r -p "Enter size of the board (default 4): " size
  echo "You chose a board of size $size x $size"
  for ((i = 0; i < size; i++)); do
    for ((j = 0; j < size; j++)); do
      set_cell i j "$i$j$((0))$((0))$((0))"
    done
  done

  echo -n "Wait..."
  spawn
  spawn
  printf "\r"
  help
  display_board
  menu
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

up() {
  move 0
}
down() {
  move 1
}
left() {
  move 2
}
right() {
  move 3
}

move() {
  local move_direction=$1
  echo "Moving ${move_direction}..."
  display_board
  echo "Score: $score"
  if [[ $win == 1 ]]; then
    echo "You win!"
    end
  fi
  if [[ $lose == 1 ]]; then
    echo "You lose!"
    end
  fi
  menu
}

game2048
