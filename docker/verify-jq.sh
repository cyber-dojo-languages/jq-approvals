function find_test_files() {
    find . -name 'test_*.jq' | sort
}

function test_methods_in_file() {
    local file=$1
    grep -o 'def test_[^:^\(]*' $file | sed 's/def //' | sort
}

function run_test_method() {
    local module=$1
    local test_method=$2
    jq -nr "include \"$module\"; $test_method"
}

function verify_test_method() {
    local module=$1
    local test_method=$2
    local base="$module.$test_method"
    echo -n "$test_method:  " 
    local received=$(run_test_method $module $test_method)
    local approved_filename="$base.approved"
    local received_filename="$base.received"
    
    echo "$received" >$received_filename
    if [ ! -f $approved_filename ]; then
        echo "failed " 
        echo "$module.$test_method: Approved file $approved_filename not found" >&2
        echo -n "  Received output is:" >&2
        cat $received_filename >&2
        exit 1
    elif [ -z "$received" ]; then
        echo "Compiling Error!" 
        exit 1
    else
        local d=$(diff -u $approved_filename $received_filename)
        if ! cmp -s $approved_filename $received_filename; then
            echo "failed" 
            echo "$module.$test_method:  " >&2
            echo "----- DIFF -----" >&2
            diff -u $approved_filename $received_filename >&2
            echo "----------------" >&2
            exit 1
        else
            echo "passed" 
            rm $received_filename
        fi
    fi
}

function run_tests_in_file() {
    local file=$1
    local module=$(echo $file | sed 's/\.jq//' | sed 's/^\.\///')
    echo "" 
    echo -n "$module." 
    #echo "" 
    local test_methods=$(test_methods_in_file $file)
    for test_method in $test_methods; do
        verify_test_method $module $test_method
        echo "" 
    done
    echo "" >&2
}

function run_tests() {
    local files=$(find_test_files)
    for file in $files; do
        run_tests_in_file $file
    done
}

function main() {
    run_tests
}

main

