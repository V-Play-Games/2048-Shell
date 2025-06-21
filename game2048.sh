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

move_rc=(
  00 # Up
  10 # Down
  00 # Left
  01 # Right
)
# 0 -> -1
# 1 -> 0
# 2 -> +1

cell_value_formatted=("    " "  2 " "  4 " "  8 " " 16 " " 32 " " 64 " "128 " "256 " "512 " "1024" "2048")
spawns=(1 1 1 1 2)
win=0
score=0
movedLastMove=0
cellValues=()
cellModified=()

set_modified() {
  cellModified[$(get_index $1 $2)]=$3
}

get_modified() {
  echo ${cellModified[$(get_index $1 $2)]}
}

end() {
  echo "Thanks for playing!"
  exit 0
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
      set_value i j 0
      set_modified i j 0
    done
  done

  echo -n "Wait..."
  spawn
  spawn
  help
  display_board
  menu
}

spawn() {
  local value=${spawns[$((RANDOM % ${#spawns[@]}))]}
  local empty_cells=()
  for ((i = 0; i < size; i++)); do
    for ((j = 0; j < size; j++)); do
      if (( $(get_value $i $j) == 0 )); then
        empty_cells+=("$i $j")
      fi
    done
  done
  if (( ${#empty_cells[@]} == 0 )); then
      return
  fi
  local random_index=$((RANDOM % ${#empty_cells[@]}))
  # shellcheck disable=SC2086
  set_value ${empty_cells[$random_index]} $value
}

get_index() {
  local row=$1
  local col=$2
  echo $((row * size + col))
}

set_value() {
  cellValues[$(get_index $1 $2)]=$3
}

get_value() {
  local row=$1
  local col=$2
  if (( row < 0 || row >= size || col < 0 || col >= size )); then
    echo -1
  else
    echo ${cellValues[$(get_index $row $col)]}
  fi
}

display_board() {
  printf "\r"
  boundary="+------+------+------+------+"
  echo "$boundary"
  for ((i = 0; i < size; i++)); do
    echo -n "| "
    for ((j = 0; j < size; j++)); do
      echo -n "${cell_value_formatted[$(get_value $i $j)]} | "
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
  local move=$1
  local moveRC=${move_rc[$move]}
  # var row = move.row * (size - 1)
  # var column = move.column * (size - 1)
  local row=$(((moveRC / 10) * (size - 1)))
  local col=$(((moveRC % 10) * (size - 1)))

  local moveRCDelta="${move_rc_changes[$move]}"
  local rowDel=$(absolute $(get_row_delta $move))
  local colDel=$(absolute $(get_col_delta $move))
  echo -n "Thinking..."
  # repeat(size) {
  #     cells[row][column].move(move)
  #     row += move.columnChange.absoluteValue
  #     column += move.rowChange.absoluteValue
  # }
  for ((i = 0; i < size; i++)); do
    move_cell $row $col $move
    row=$((row + colDel))
    col=$((col + rowDel))
  done
  # if (anyMove) {
  #     spawn()
  # }
  if ((movedLastMove == 1)); then
    spawn
  fi
  for ((i = 0; i < size; i++)); do
    for ((j = 0; j < size; j++)); do
      set_modified $i $j 0
    done
  done
  display_board
  echo "Score: $score"
  if (( win == 1 )); then
    echo "You win!"
    end
  fi
  if (( $(check_lose) == 1 )); then
    echo "You lose!"
    end
  fi
  menu
}

absolute() {
  local value=$1
  if (( value < 0 )); then
    echo $(( -value ))
  else
    echo $value
  fi
}

get_row_delta() {
  local move=$1
  local moveRCDelta=${move_rc_changes[$move]}
  echo $((moveRCDelta / 10 - 1))
}

get_col_delta() {
  local move=$1
  local moveRCDelta=${move_rc_changes[$move]}
  echo $((moveRCDelta % 10 - 1))
}

move_cell() {
  local row=$1
  local col=$2
  local move=$3
  local rowDel=$(get_row_delta "$move")
  local colDel=$(get_col_delta "$move")
  local cell=$(get_value "$row" "$col")
  if (( cell == -1 )); then
    return
  fi
  local targetRow=$((row + rowDel))
  local targetCol=$((col + colDel))
  local target=$(get_value $targetRow $targetCol)
  if (( target != -1 && cell != 0 )); then
    # if (target.isEmpty) {
    #     val targetRow = target.row
    #     val targetCol = target.column
    #     target.setCoordinates(this.row, this.column)
    #     this.setCoordinates(targetRow, targetCol)
    #     isMoved = true
    #     move(move)
    #     return
    if (( "$target" == "0" )); then
      # Move the cell to the empty target cell
      local targetModified=$(get_modified $targetRow $targetCol)
      local thisModified=$(get_modified $row $col)
      set_value $targetRow $targetCol $cell
      set_modified $targetRow $targetCol $thisModified
      set_value $row $col 0
      set_modified $row $col $targetModified
      movedLastMove=1
      move_cell $targetRow $targetCol $move
      return
    elif (( target == cell && $(get_modified $targetRow $targetCol) == 0 )); then
        set_value $targetRow $targetCol $((target + 1))
        set_modified $targetRow $targetCol 1
        set_value $row $col 0
        movedLastMove=1
    fi
    # } else if (target.type == this.type && !target.isModified) {
    #     target.type = CellType.forValue(this.value * 2)!!
    #     target.isModified = true
    #     this.type = CellType.C0
    #     isMoved = true
    # }
  fi
  move_cell $((row - rowDel)) $((col - colDel)) $move
}

check_lose() {
  # lose = flatCells.none { it.canMove() }
  echo 0
}

game2048
