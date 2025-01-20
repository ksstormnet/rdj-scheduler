#!/bin/bash
# shellcheck source=lib/logging.sh
set -u
#
# State Manager Module
#
# Key Data Structures:
# - CATEGORIES: Maps category IDs to their names (e.g., image, music by year)
# - SUBCATEGORIES: Maps subcategory IDs to names
# - PARENT_IDS: Maps subcategory IDs to parent category IDs
# - ROTATIONS: Maps rotation IDs to their names
# - ROTATION_LISTS: Maps rotation_id:minute to category/subcat IDs
# - ROTATION_TIMES: Ordered array of minutes in rotation patterns
#
# Common Patterns:
# - Image: Category ID 1, Subcategory ID 48
# - Commercial breaks: Minutes 00, 15, 30, 45 in rotations
# - Standard jingles: Minutes 05, 20, 35, 50
# - Premium spots: Minutes 14, 29, 44, 59
#
# Maintains runtime state information about categories, subcategories and rotations

# Load dependencies 
# shellcheck source=lib/logging.sh
. "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

declare -g -A CATEGORIES=()       # Maps category IDs to names
declare -g -A SUBCATEGORIES=()   # Maps subcategory IDs to names
declare -g -A PARENT_IDS=()      # Maps subcategory IDs to parent category IDs
declare -g -A ROTATIONS=()       # Maps rotation IDs to names
declare -g -A ROTATION_LISTS=()  # Maps rotation_id:minute to category/subcat IDs
declare -g -a ROTATION_TIMES=()  # Ordered list of rotation minutes

# Initialize the state from database
init_state() {
    if ! load_categories; then
        log_error "Failed to load category state"
        return 1
    fi

    if ! load_subcategories; then
        log_error "Failed to load subcategory state"
        return 1
    fi

    if ! load_rotations; then
        log_error "Failed to load rotation state"
        return 1
    fi

    if ! load_rotation_lists; then
        log_error "Failed to load rotation list state"
        return 1
    fi

    log_debug "State manager initialized successfully"
    return 0
}
# Load categories from database
load_categories() {
    local query="SELECT ID, name FROM category ORDER BY ID"
    while IFS=$'\t' read -r id name; do
        CATEGORIES[$id]="$name"
    done < <(mysql -BN radiodj -e "$query")
    
    if [[ ${#CATEGORIES[@]} -eq 0 ]]; then
        log_error "No categories loaded"
        return 1
    fi
    return 0
}

# Load subcategories and their relationships
load_subcategories() {
    local query="SELECT ID, parentid, name FROM subcategory ORDER BY ID"
    while IFS=$'\t' read -r id parent name; do
        SUBCATEGORIES[$id]="$name"
        PARENT_IDS[$id]="$parent"
    done < <(mysql -BN radiodj -e "$query")
    
    if [[ ${#SUBCATEGORIES[@]} -eq 0 ]]; then
        log_error "No subcategories loaded"
        return 1
    fi
    return 0
}


# Get category ID by name
get_category_id() {
    local search_name="$1"
    for id in "${!CATEGORIES[@]}"; do
        if [[ "${CATEGORIES[$id]}" == "$search_name" ]]; then
            echo "$id"
            return 0
        fi
    done
    return 1
}

# Get subcategory details by name
# Returns: parentID=X, ID=Y, name="Z"
get_subcategory_details() {
    local search_name="$1"
    for id in "${!SUBCATEGORIES[@]}"; do
        if [[ "${SUBCATEGORIES[$id]}" == "$search_name" ]]; then
            printf "parentID=%s, ID=%s, name=\"%s\"\n" \
                    "${PARENT_IDS[$id]}" "$id" "${SUBCATEGORIES[$id]}"
            return 0
        fi
    done
    return 1
}

# Get template pattern by ID
get_template_pattern() {
    local template_id="$1"
    if [[ -n "${TEMPLATES[$template_id]}" ]]; then
        echo "${TEMPLATES[$template_id]}"
        return 0
    fi
    return 1
}

# Load rotations from database
load_rotations() {
    local query="SELECT ID, name FROM rotations ORDER BY ID"
    while IFS=$'\t' read -r id name; do
        ROTATIONS[$id]="$name"
    done < <(mysql -BN radiodj -e "$query")
    
    if [[ ${#ROTATIONS[@]} -eq 0 ]]; then
        log_error "No rotations loaded"
        return 1
    fi
    return 0
}

# Load rotation list entries from database
load_rotation_lists() {
    local query="SELECT pID, ord, catID, subID FROM rotations_list ORDER BY pID, ord"
    ROTATION_TIMES=()
    while IFS=$'\t' read -r pid ord catid subid; do
        # Store as rot_id:ord -> cat_id:sub_id
        local key="${pid}:${ord}"  
        local value="${catid}:${subid}"
        ROTATION_LISTS[$key]="$value"
        
        # Track unique times for ordered access
        local found=0
        for time in "${ROTATION_TIMES[@]}"; do
            [[ $time == "$ord" ]] && { found=1; break; }
        done
        [[ $found -eq 0 ]] && ROTATION_TIMES+=("$ord")
    done < <(mysql -BN radiodj -e "$query")
    
    if [[ ${#ROTATION_LISTS[@]} -eq 0 ]]; then
        log_error "No rotation list entries loaded"
        return 1
    fi

    # Sort minutes in ascending order
    mapfile -t ROTATION_TIMES < <(printf '%s\n' "${ROTATION_TIMES[@]}" | sort -n)
    
    return 0
}

# Get ordered elements in a rotation template
get_rotation_elements() {
    local rotation_id="$1"
    # Validate input
    if [[ -z "$rotation_id" ]]; then
        log_error "No rotation ID provided"
        return 1
    fi
    
    # Validate rotation exists
    if [[ -z "${ROTATIONS[$rotation_id]:-}" ]]; then
        log_error "Invalid rotation ID: $rotation_id"
        return 1
    fi

    local elements=()
    
    for minute in "${ROTATION_TIMES[@]}"; do
        local key="${rotation_id}:${minute}"
        if [[ -n "${ROTATION_LISTS[${key}]:-}" ]]; then
            local catid subid
            IFS=: read -r catid subid <<< "${ROTATION_LISTS[$key]:-}"
            elements+=("minute=${minute}, catID=${catid}, subID=${subid}")
        fi
    done
    
    if [[ ${#elements[@]} -eq 0 ]]; then
        log_warn "No elements found for rotation ID $rotation_id"
        return 0
    fi
    
    printf "%s\n" "${elements[@]}"
    return 0
}
# Get rotation ID by name
get_rotation_id() {
    local search_name="$1"
    if [[ -z "$search_name" ]]; then
        log_error "No rotation name provided"
        return 1
    fi

    for id in "${!ROTATIONS[@]}"; do
        if [[ "${ROTATIONS[$id]:-}" == "$search_name" ]]; then
            echo "$id"
            return 0
        fi
    done
    return 1
}

# Initialize state when sourced
if ! init_state; then
    log_error "Failed to initialize state manager"
    exit 1
fi

# Get common category details
get_jingle_category() {
    local jingle_cat_id=2
    local name="${CATEGORIES[$jingle_cat_id]}"
    echo "jingleID=${jingle_cat_id}, name=\"${name}\""
    return 0
}

get_image_category() {
    local category_id=1
    local subcat_id=48
    local name="${SUBCATEGORIES[$subcat_id]}"
    echo "imageID=${subcat_id}, parentID=${category_id}, name=\"${name}\""
    return 0
}

get_commercial_category() {
    local category_id=5
    local name="${CATEGORIES[$category_id]}"
    echo "commercialID=${category_id}, name=\"${name}\""
    return 0
}

# Validate category/subcategory relationship
validate_category_relation() {
    local category_id="$1"
    local subcategory_id="$2"

    # Check category exists
    if [[ -z "${CATEGORIES[$category_id]}" ]]; then
        log_error "Category ID ${category_id} not found"
        return 1
    fi

    # Check subcategory exists and parent matches
    if [[ -n "$subcategory_id" ]]; then
        if [[ -z "${SUBCATEGORIES[$subcategory_id]}" ]]; then
            log_error "Subcategory ID ${subcategory_id} not found"
            return 1
        fi
        if [[ "${PARENT_IDS[$subcategory_id]}" != "$category_id" ]]; then
            log_error "Subcategory ${subcategory_id} does not belong to category ${category_id}"
            return 1
        fi
    fi

    return 0
}

# Check for commercial break pattern at given minute
is_commercial_break() {
    local minute="$1"
    case "$minute" in
        0|15|30|45) return 0 ;;
        *) return 1 ;;
    esac
}

# Check for premium spot pattern at given minute
is_premium_spot() {
    local minute="$1"
    case "$minute" in
        14|29|44|59) return 0 ;;
        *) return 1 ;;
    esac
}

# Get rotation pattern elements by type (commercials, jingles, etc)
get_rotation_elements_by_type() {
    local rotation_id="$1"
    local category_id="$2"
    
    # Validate input
    if [[ -z "$rotation_id" ]]; then
        log_error "No rotation ID provided"
        return 1
    fi
    
    if [[ -z "$category_id" ]]; then
        log_error "No category ID provided"
        return 1
    fi

    # Validate rotation exists
    if [[ -z "${ROTATIONS[$rotation_id]:-}" ]]; then
        log_error "Invalid rotation ID: $rotation_id"
        return 1
    fi

    local elements=()

    for minute in "${ROTATION_TIMES[@]}"; do
        local key="${rotation_id}:${minute}"
        if [[ -n "${ROTATION_LISTS[$key]:-}" ]]; then
            local catid subid
            IFS=: read -r catid subid <<< "${ROTATION_LISTS[$key]:-}"
            if [[ "$catid" == "$category_id" ]]; then
                elements+=("minute=${minute}, catID=${catid}, subID=${subid}")
            fi
        fi
    done

    printf "%s\n" "${elements[@]}"
    return 0
}

# Get full rotation pattern with category names
get_rotation_pattern() {
    local rotation_id="$1"
    
    # Validate input
    if [[ -z "$rotation_id" ]]; then
        log_error "No rotation ID provided"
        return 1
    fi

    # Validate rotation exists  
    if [[ -z "${ROTATIONS[$rotation_id]:-}" ]]; then
        log_error "Invalid rotation ID: $rotation_id"
        return 1
    fi

    local pattern=()

    for minute in "${ROTATION_TIMES[@]}"; do
        local key="${rotation_id}:${minute}"
        if [[ -n "${ROTATION_LISTS[$key]:-}" ]]; then
            local catid subid
            IFS=: read -r catid subid <<< "${ROTATION_LISTS[$key]:-}"
            pattern+=("${minute}:${CATEGORIES[$catid]:-Unknown}${subid:+:${SUBCATEGORIES[$subid]:-Unknown}}")
        fi
    done

    printf "%s\n" "${pattern[@]}"
    return 0
}

# Get the last occurrence of a category in a rotation before given minute
get_last_occurrence() {
    local rotation_id="$1"
    local category_id="$2"
    local target_minute="$3"
    
    # Validate input
    if [[ -z "$rotation_id" || -z "$category_id" || -z "$target_minute" ]]; then
        log_error "Missing required parameters for get_last_occurrence"
        return 1
    fi
    
    # Validate rotation exists
    if [[ -z "${ROTATIONS[$rotation_id]:-}" ]]; then
        log_error "Invalid rotation ID: $rotation_id"
        return 1
    fi

    local last_minute=-1

    for minute in "${ROTATION_TIMES[@]}"; do
        [[ $minute -ge $target_minute ]] && break
        local key="${rotation_id}:${minute}"
        if [[ -n "${ROTATION_LISTS[$key]:-}" ]]; then
            local catid
            IFS=: read -r catid _ <<< "${ROTATION_LISTS[$key]:-}"
            if [[ "$catid" == "$category_id" ]]; then
                last_minute=$minute
            fi
        fi
    done

    echo "$last_minute"
    return 0
}
