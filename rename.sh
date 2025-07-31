#!/usr/bin/env bash

# Script to rename the template project to a new name. 

TEMPLATE_GAME_SNAKE="template_game" 
TEMPLATE_LIB_SNAKE="template_lib" 

read -p "Enter new project name (e.g., 'My Awesome Game'): " NEW_PROJECT_NAME 

if [[ -z "$NEW_PROJECT_NAME" ]]; then 
    echo "No project name entered. Exiting." 
    exit 1 
fi 

NEW_GAME_SNAKE=$(echo "$NEW_PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_') 
NEW_LIB_SNAKE="${NEW_GAME_SNAKE}_lib" 

# 3. Rename directories and files 
echo "Renaming directories and files..." 
find . -depth -name "*template_*" -exec bash -c '
    OLD_NAME="$1" 
    NEW_NAME=$(echo "$OLD_NAME" | sed "s/'"$TEMPLATE_GAME_SNAKE"'/'"$NEW_GAME_SNAKE"'/g" | sed "s/'"$TEMPLATE_LIB_SNAKE"'/'"$NEW_LIB_SNAKE"'/g") 
    if [ "$OLD_NAME" != "$NEW_NAME" ]; then 
        mv "$OLD_NAME" "$NEW_NAME" 
        echo "Renamed: $OLD_NAME -> $NEW_NAME" 
    fi 
' bash {} \; 

echo "Replacing content in files..." 
grep -rl "$TEMPLATE_GAME_SNAKE" . --exclude-dir=target --exclude-dir=.git | while read -r file; do 
    sed -i.bak "s/$TEMPLATE_GAME_SNAKE/$NEW_GAME_SNAKE/g" "$file" 
    rm "$file.bak" 
    echo "Updated content in: $file" 
done 

grep -rl "$TEMPLATE_LIB_SNAKE" . --exclude-dir=target --exclude-dir=.git | while read -r file; do 
    sed -i.bak "s/$TEMPLATE_LIB_SNAKE/$NEW_LIB_SNAKE/g" "$file" 
    rm "$file.bak" 
    echo "Updated content in: $file" 
done 

echo "Project setup is complete!" 
