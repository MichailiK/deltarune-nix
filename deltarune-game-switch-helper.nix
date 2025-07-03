{
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "deltarune-game-switch-helper";

  text = ''
    # This script faciliates switching between chapters and going to chapter select.

    DELTARUNEDIR=""

    if [ -n "''${1-}" ]; then
      # Use the first argument from the user as the DELTARUNE directory
      DELTARUNEDIR="$1"
    else
      # Use the script's folder as the DELTARUNE directory
      DELTARUNEDIR=$(dirname "''${BASH_SOURCE[0]}")
    fi

    # Try to determine if the directory looks indeed like a DELTARUNE installation
    if [ ! -f "$DELTARUNEDIR"/deltarune ] || ! ls "$DELTARUNEDIR"/chapter{1,2,3,4}_linux &>/dev/null; then
      echo "$0: This path ($DELTARUNEDIR) does not look like a DELTARUNE installation."
      exit 1
    fi


    # yoyo games runner does not follow the XDG base directory specs to the tin,
    # they use $HOME/.config instead of $XDG_CONFIG_HOME
    SAVEDIR="$HOME/.config/DELTARUNE"

    CHAPTERSELECT_FILE="$SAVEDIR/deltarune_chapterselect"
    CHAPTER1_FILE="$SAVEDIR/deltarune_chapter1"
    CHAPTER2_FILE="$SAVEDIR/deltarune_chapter2"
    CHAPTER3_FILE="$SAVEDIR/deltarune_chapter3"
    CHAPTER4_FILE="$SAVEDIR/deltarune_chapter4"

    # Just in case
    mkdir -p "$SAVEDIR"

    # remove the trigger files in case they're present (can happen if a chapter
    # got launched individually & the user tried to switch chapters.)
    rm -f "$CHAPTERSELECT_FILE" "$CHAPTER1_FILE" "$CHAPTER2_FILE" "$CHAPTER3_FILE" "$CHAPTER4_FILE"

    # Launch game the first time
    "$DELTARUNEDIR"/deltarune

    # (Next time) when DELTARUNE exits, we're gonna check if the trigger files
    # exist & switch to the appropiate game/chapter if there is.
    while true
    do
      if [ -f "$CHAPTERSELECT_FILE" ]; then
        rm "$CHAPTERSELECT_FILE"
        "$DELTARUNEDIR"/deltarune
      elif [ -f "$CHAPTER1_FILE" ]; then
        rm "$CHAPTER1_FILE"
        "$DELTARUNEDIR"/chapter1_linux/deltarune
      elif [ -f "$CHAPTER2_FILE" ]; then
        rm "$CHAPTER2_FILE"
        "$DELTARUNEDIR"/chapter2_linux/deltarune
      elif [ -f "$CHAPTER3_FILE" ]; then
        rm "$CHAPTER3_FILE"
        "$DELTARUNEDIR"/chapter3_linux/deltarune
      elif [ -f "$CHAPTER4_FILE" ]; then
        rm "$CHAPTER4_FILE"
        "$DELTARUNEDIR"/chapter4_linux/deltarune
      else break; fi
    done
  '';
}