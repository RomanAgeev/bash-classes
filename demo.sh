#!/bin/bash

set -uo pipefail

source ./utils/_main.sh

# Metaclass
new_class dog

# Static set
dog__set_default_sound() {
    __set_dog_static_field default_sound "${1:?}"
}

# Static get
dog__get_default_sound() {
    __get_dog_static_field default_sound
}

# Constructor
dog__new() {
    local this="${1:?}"

    # Init an internal field to check instance existence: __exist_dog "$this"
    __init_dog "$this"

    __set_dog_field "$this" name "${2:?}"
    __set_dog_field "$this" age "${3:?}"
    __set_dog_field "$this" "breed" "${4:?}"
    __set_dog_array_field "$this" walking
}

# Destructor
dog__free() {
    local this="${1:?}"

    __exist_dog "$this" && __free_dog "$this"
}

dog__get_breed() {
    local this="${1:?}"
    local result="${2:?}"

    local breed; __get_dog_field "$this" breed

    eval "$result=\$breed"
}

dog__get_info() {
    local this="${1:?}"
    local result="${2:?}"

    local name; __get_dog_field "$this" name
    local age; __get_dog_field "$this" age
    local walking; __get_dog_array_field "$this" walking

    local info;
    printf -v info "%s is %d years old, walking at (%s)" "$name" "$age" "${walking[*]:-}"

    eval "$result=\$info"
}

dog__speak() {
    local this="${1:?}"
    local default_sound; dog__get_default_sound
    local sound="${2:-$default_sound}"

    local name; __get_dog_field "$this" name

    printf "%s says \"%s!\"\n" "$name" "$sound"
}

dog__add_walking() {
    local this="${1:?}"
    local time="${2:?}"

    local walking; __get_dog_array_field "$this" walking
    walking+=("$time")
    __set_dog_array_field "$this" walking "${walking[@]}"
}

dog__set_default_sound "Woof"

dog__new miles "Miles" 4 "Jack Russell Terrier"
dog__new buddy "Buddy" 9 "Dachshund"
dog__new jack "Jack" 3 "Bulldog"
dog__new jim "Jim" 5 "Bulldog"

dog__add_walking miles "10am"
dog__add_walking miles "8pm"

my_dogs=( miles buddy jack jim )

for dog in "${my_dogs[@]}"; do
    dog__get_info "$dog" dog_info
    dog__get_breed "$dog" dog_breed
    printf "Breed: %s\n Info: %s\n" "$dog_breed" "$dog_info"
done

echo

dog__speak miles "Yap"
dog__speak buddy
dog__speak jack
dog__speak jim

for dog in "${my_dogs[@]}"; do
    dog__free "$dog"
done

# NOTE: Uncomment to check the effect of the 'dog_free' destructor
# compgen -v | grep dog__
