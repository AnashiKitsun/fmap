#!/bin/bash
# Get path arg or default it to .
path=${1:-.}
# Now the selector will either be (/ or .), an unformatted selector, or a valid selection. (or invalid, but that will be handled elsewhere.)
# We need to bring any of these to any selector formatted as .{selector}
# Change all / to .
selector=$(echo $path | /usr/bin/tr / .)
# add . to start if it isn't there
if ! [[ $selector =~ ^[/.] ]]; then selector="."$selector; fi

echo Selection path: $selector

# Start at specified path and get all values from selection
selected_instructions=$(/usr/bin/jq -r $selector' | recurse | strings' $PWD/base.fmap)
# loop through instructions and execute them
echo "Instructions to run: \n ${selected_instructions[@]}"
read -p "Are you sure? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo Operation cancelled.
  exit 0
fi

echo "Proceeding..."
for instruction in ${selected_instructions[@]}
do
  echo "Executing instruction: $instruction"
  # Split bits of data
  IFS='|' read -ra instruction_set <<< "$instruction"
  # Simplify which part is which for easier reference
  source=${instruction_set[0]} # Copy from
  dest=${instruction_set[1]} # Copy to
  modx=${instruction_set[2]} # Chmod +x?
  method=${instruction_set[3]} # Command to link it with? [IMPORTANT TO CHECK]
  # Format data as necessary
  source=$(echo $source | /usr/bin/sed 's/{ROOT}/'$(echo $PWD | /usr/bin/sed 's/\//\\\//g')'/g') # This weird little thing makes the working directory valid for /usr/bin/sed.
  dest=$(realpath $dest)
  echo $dest
  # Modx doesn't need formatting
  method=$(echo $method | /usr/bin/tr _ ' ') # Sub underscores for spaces
  # Run and interpret the command
  echo "Making parent dir $(realpath $dest"/../")"
  echo $dest
  mkdir -p $dest"/../"
  echo "Linking..."
  eval $method $source $dest
  if [ $modx = 1 ]
  then
    chmod +x $dest
    echo "$dest set as executable"
  fi
done
