# Turn colors in this script off by setting the NO_COLOR variable in your
# environment to any value:
#
# $ NO_COLOR=1 test.sh
NO_COLOR=${NO_COLOR:-""}
if [ -z "$NO_COLOR" ]; then
  header_color=$'\e[1;33m'
  error_color=$'\e[1;31m'
  reset=$'\e[0m'
else
  header_color=''
  error_color=''
  reset=''
fi


function header_text {
  echo "$header_color$*$reset"
}

function error_text {
  echo "$error_color$*$reset"
}
