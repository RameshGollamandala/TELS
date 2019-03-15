#!/bin/bash

#set -x

# Import Environment Variables

. /apps/Callidus/tels/integrator/tels_setenv_variables.sh

###############################################################################
# Function : Validate a leading HDR line
###############################################################################

ValidateHeader()
{

  # HDR|15122018

  echo "[ValidateFile] Validate Header - $1"

  IFS='|' read -r -a hdr_array <<< "$1"

  hdr_field_count=${#hdr_array[@]}

  if [ "$hdr_field_count" -ne "2" ]; then
    echo "[ValidateFile] Validate Header - Number of fields is not 2 ($hdr_field_count)."
    return 1
  fi

  if [ "${hdr_array[0]}" != "HDR" ]; then
    echo "[ValidateFile] Validate Header - First field is not HDR (${hdr_array[0]})."
    return 1
  fi

#  hdr_date="$( date -d ${hdr_array[1]} +'%d%m%Y' 2> /dev/null )"
#
#  if [ "$hdr_date" = "" ]; then
#    echo "[ValidateFile] Validate Header - Second field is not a date (${hdr_array[1]})."
#    return 1
#  fi

  return 0

}

###############################################################################
# Function : Validate a trailing TRL line
###############################################################################

ValidateTrailer()
{

  # TRL|7763681

  echo "[ValidateFile] Validate Trailer - $1"

  IFS='|' read -r -a trl_array <<< "$1"

  trl_field_count=${#trl_array[@]}

  if [ "$trl_field_count" -ne "2" ] ; then
    echo "[ValidateFile] Validate Trailer - Number of fields is not 2 ($trl_field_count)."
    return 1
  fi

  if [ "${trl_array[0]}" != "TRL" ] ; then
    echo "[ValidateFile] Validate Trailer - First field is not TRL (${trl_array[0]})."
    return 1
  fi

  if ! [[ "${trl_array[1]}" =~ ^[1-9][0-9]*|0$ ]] ; then
    echo "[ValidateFile] Validate Trailer - Second field is not an integer (${trl_array[1]})."
    return 1
  fi

  if [ "${trl_array[1]}" -ne "$2" ] ; then
    echo "[ValidateFile] Validate Trailer - Actual record count ($2) does not match Trailer record count (${trl_array[1]})"
    return 1
  fi

  return 0

}

###############################################################################
# Function : Check each line has the same number of fields
###############################################################################

ValidateLines()
{

  #printf "$(date +%T) Start\n"

  file_name=$1

  max_line_count=$2

  tmp_field_count_list="tmp_field_count_list.txt"
  tmp_unique_field_count_list="tmp_unique_field_count_list.txt"
  tmp_output_list="tmp_output_list.txt"

  cat $file_name | sed '1d' | sed '$d' | awk -F'|' '{ printf "%s|%s\n",NF,NR }' > $tmp_field_count_list

  cat $tmp_field_count_list | sort -nru -t'|' -k1 | awk -F'|' '{ printf "%s\n",$1 }' > $tmp_unique_field_count_list

  field_count_len=0
  line_count_len=0
  last_line_number_len=0

  output_count=0

  while read field_count || [[ -n $field_count ]]; do
    ((output_count++))
    if (( ${#field_count} > $field_count_len )); then
      field_count_len=${#field_count}
    fi
    line_count=$(grep -c "^$field_count|" $tmp_field_count_list)
    if (( ${#line_count} > $line_count_len )); then
      line_count_len=${#line_count}
    fi
    last_line_number=$(tac $tmp_field_count_list | grep -m 1 "^$field_count|" | awk -F '|' '{ print $2 }')
    if (( ${#last_line_number} > $last_line_number_len )); then
      last_line_number_len=${#last_line_number}
    fi
    last_line=$(cat $file_name | awk "NR==$last_line_number")
    printf "%s~%s~%s~%s\n" "$field_count" "$line_count" "$last_line_number" "$last_line" >> $tmp_output_list
  done < "$tmp_unique_field_count_list"

  if (( $output_count > 1 )); then
    echo "[ValidateFile] Validate Lines - Invalid Line Counts"
    echo
    awk -F '~' '{ printf "               Fields: %*s, Line Count: %*s, Last Line Number: %*s\n               Last Line Text: \"%s\"\n\n", a, $1, b, $2, c, $3, $4 }' a="$field_count_len" b="$line_count_len" c="$last_line_number_len" "$tmp_output_list"
    retvar=1
  else
    echo "[ValidateFile] Validate Lines - Valid Line Counts"
    retvar=0
  fi

  #printf "$(date +%T) End\n"

  [[ -f "$tmp_field_count_list" ]] && rm "$tmp_field_count_list"
  [[ -f "$tmp_unique_field_count_list" ]] && rm "$tmp_unique_field_count_list"
  [[ -f "$tmp_output_list" ]] && rm "$tmp_output_list"

  return $retvar

}

###############################################################################
# Function : Validate a file with a leading HDR line and a trailing TRL line
###############################################################################

ValidateFile()
{

  data_file_name=$1

  hdr_line=""
  trl_line=""

  line_count=0

  cd $infasrcdir

  if [ "$data_file_name" != "" ]; then
    hdr_line=`head -1 $data_file_name`
    line_count=`cat $data_file_name | sed '1d' | sed '$d' | wc --lines`
    trl_line=`tail -1 $data_file_name`
  fi

  ValidateHeader $hdr_line # | tee -a $autoloaderlog $logfile
  hdr_status=$?

  if [ "$hdr_status" -ne "0" ]; then
    echo "[ValidateFile] Validate Header - Invalid Header Record"
    return 1
  fi

  echo "[ValidateFile] Validate Header - Valid Header Record"

  ValidateTrailer $trl_line $line_count # | tee -a $autoloaderlog $logfile
  trl_status=$?

  if [ "$trl_status" -ne "0" ]; then
    echo "[ValidateFile] Validate Trailer - Invalid Trailer Record"
    return 1
  fi

  echo "[ValidateFile] Validate Trailer - Valid Trailer Record"

  ValidateLines $data_file_name $line_count

  return 0

}

