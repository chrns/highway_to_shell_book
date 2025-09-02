#!/usr/bin/env bash

FIELD_WIDTH=5
FIELD_HEIGHT=20
STATS_WIDTH=15
SCREEN_WIDTH=$((FIELD_WIDTH * 2 + STATS_WIDTH))
SCREEN_HEIGHT=$FIELD_HEIGHT
SNAIL="\e[33m@\e[0m"
OBSTACLE="\e[31mY\e[0m"
LIFE_BONUS="\e[32m+\e[0m"
LIVES=3
SCORE=0
LEVEL=1
SNAIL_POSITION=$((FIELD_WIDTH / 2))
SPEED=0.1
OBSTACLE_DENSITY=5

tput_clear_screen=$(tput clear)
tput_home_cursor=$(tput cup 0 0)
tput_move_cursor=$(tput cup)
hide_cursor=$(tput civis)
show_cursor=$(tput cnorm)

cleanup() {
  printf "\n"
  printf "Exiting game...\n"
  printf "%s" "$show_cursor"
  stty sane
  printf "%s" "$tput_clear_screen"
  printf "Game Over!\n"
  printf "\nGame statistics:\n"
  printf " - Scode: $SCORE\n"
  printf " - Level: $LEVEL\n"
  printf " - Lives: $LIVES\n"
  exit 0
}
trap cleanup SIGINT SIGTERM

stty -icanon -echo

declare -a field

draw_screen() {
  local row col

  printf "%s" "$tput_home_cursor"

  for ((row=0; row<FIELD_HEIGHT; row++)); do
    printf " | "
    for ((col=0; col<FIELD_WIDTH; col++)); do
      if (( row == FIELD_HEIGHT - 1 )) && (( col == SNAIL_POSITION )); then
        printf " $SNAIL "
      else
        printf " ${field[$((row*FIELD_WIDTH + col))]} "
      fi
    done

    printf " | "
    case $row in
      1) printf "SCORE: %d" "$SCORE" ;;
      3) printf "LIVES: %d" "$LIVES" ;;
      5) printf "LEVEL: %d" "$LEVEL" ;;
      *) printf "" ;;
    esac
    printf "%s" "$(tput el)"
    printf "\n"
  done
}

# Update game state
update_game() {
  local row col new_field_row

  for ((row=FIELD_HEIGHT-2; row>=0; row--)); do
    for ((col=0; col<FIELD_WIDTH; col++)); do
      field[$(( (row+1)*FIELD_WIDTH + col ))]=${field[$(( row*FIELD_WIDTH + col ))]}
    done
  done

  for ((col=0; col<FIELD_WIDTH; col++)); do
    field[$col]=" "
  done

  if (( RANDOM % OBSTACLE_DENSITY == 0 )); then
    obstacle_pos=$((RANDOM % FIELD_WIDTH))
    field[$obstacle_pos]="$OBSTACLE"
  elif (( RANDOM % 100 == 0 )); then
    bonus_pos=$((RANDOM % FIELD_WIDTH))
    field[$bonus_pos]="$LIFE_BONUS"
  fi

  local snail_cell=${field[$(( (FIELD_HEIGHT-1)*FIELD_WIDTH + SNAIL_POSITION ))]}
  if [ "$snail_cell" == "$OBSTACLE" ]; then
    ((LIVES--))
  elif [ "$snail_cell" == "$LIFE_BONUS" ]; then
    ((LIVES++))
  fi

  if ((LIVES <= 0)); then
    cleanup
  fi

  ((SCORE++))
  if ((SCORE % 50 == 0)); then
    ((LEVEL++))
    SPEED=$(awk "BEGIN {print $SPEED - 0.005}")
    if ((OBSTACLE_DENSITY > 2)); then
        ((OBSTACLE_DENSITY--))
    fi
  fi
}

main_loop() {
  local key
  
  printf "%s" "$hide_cursor"
  printf "%s" "$tput_clear_screen"

  for ((i=0; i<FIELD_WIDTH*FIELD_HEIGHT; i++)); do
    field[$i]=" "
  done

  draw_screen

  while true; do
    read -n1 -t $SPEED key 2>/dev/null
    
    if [[ "$key" == "q" ]]; then
        cleanup
    fi

    if [[ "$key" == $'\x1b' ]]; then
      read -n2 -t 0.001 key
      case "$key" in
        '[C') ((SNAIL_POSITION++)) ;;
        '[D') ((SNAIL_POSITION--)) ;;
      esac
    fi

    if ((SNAIL_POSITION < 0)); then
      SNAIL_POSITION=0
    elif ((SNAIL_POSITION >= FIELD_WIDTH)); then
      SNAIL_POSITION=$((FIELD_WIDTH-1))
    fi

    update_game
    draw_screen
  done
}

main_loop