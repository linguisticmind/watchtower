# timew-chart.bash - display a Timewarrior chart report
# copyright (c) 2025  Alex Rogers <https://github.com/linguisticmind>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# version: 0.1.0

shopt -s extglob

declare -a range

declare -A re

re[day_of_week]='monday|tuesday|wednesday|thursday|friday|saturday|sunday'
re[month_of_year]='january|february|march|april|may|june|july|august|september|october|november|december'

re[simple_date]='[0-9]{4}[0-9]{2}[0-9]{2}|[0-9]{4}W[0-9]{2}|[0-9]{4}[0-9]{3}'
re[extended_date]='[0-9]{4}-[0-9]{2}(-[0-9]{2})?|[0-9]{4}-[0-9]{3}|[0-9]{4}-W[0-9]{2}([0-9])?'

re[named_date]="now|today|yesterday|tomorrow|${re[day_of_week]}|${re[month_of_year]}|[0-9]{2}:[0-9]{2}(:[0-9]{2})?(am|a|pm|p)?|[0-9]+st|[0-9]+nd|[0-9]+rd|[0-9]+th|[0-9]{9,}|later|someday|sopd|eopd|sod|eod|sond|eond|sopw|eopw|sow|eow|sonw|eonw|sopww|eopww|soww|eoww|sonww|eonww|sopm|eopm|som|eom|sonm|eonm|sopq|eopq|soq|eoq|sonq|eonq|sopy|eopy|soy|eoy|sony|eony|easter|eastermonday|ascension|pentecost|goodfriday|midsommar|midsommarafton|juhannus"

re[simple_time]='[0-9]{2}[0-9]{2}([0-9]{2})?(Z|(\+|-)[0-9]{2}([0-9]{2})?)?'
re[extended_time]='[0-9]{2}:[0-9]{2}(:[0-9]{2})?(Z|(\+|-)[0-9]{2}:[0-9]{2})?'

re[named_time]="[0-9]{2}(am|a|pm|p)|[0-9]+st|[0-9]+nd|[0-9]+rd|[0-9]+th|${re[day_of_week]}|${re[month_of_year]}"

re[1]="^${re[extended_date]}(T${re[extended_time]})?$"
re[2]="^${re[simple_date]}(T${re[simple_time]})?$"
re[3]="^${re[extended_time]}$"
re[4]="^${re[simple_time]}$"
re[5]="^${re[named_date]}$"
re[6]="^${re[named_time]}$"

re[date]="${re[1]}|${re[2]}|${re[3]}|${re[4]}|${re[5]}|${re[6]}"

re[1]='^P([0-9]+Y)?([0-9]+M)?([0-9]+D)?(T([0-9]+H)?([0-9]+M)?([0-9]+S)?)?$'
re[2]='^P[0-9]+W$'
re[3]='^[0-9]+(\.[0-9]+)?(annual|biannual|bimonthly|biweekly|biyearly|daily|days|day|d|fortnight|hours|hour|hrs|hr|h|hours|hour|hrs|hr|h|monthly|months|month|mnths|mths|mth|mos|mo|m|quarterly|quarters|quarter|qrtrs|qtr|q|semiannual|sennight|seconds|second|secs|sec|s|weekdays|weekly|weeks|week|wks|wk|w|yearly|years|year|yrs|yr|y)$'

re[duration]="${re[1]}|${re[2]}|${re[3]}"

if
  [[ $1 == 'from' && $2 =~ ${re[date]} && $3 == @(to|-) && $4 =~ ${re[date]} ]] ||
  [[ $1 == 'from' && $2 =~ ${re[date]} && $3 == 'for' && $4 =~ ${re[duration]} ]]
then
  range=("${@:1:4}")
  shift 4
elif
  [[ $1 =~ ${re[date]} && $2 == @(to|-) && $3 =~ ${re[date]} ]] ||
  [[ $1 =~ ${re[date]} && $2 == 'for' && $3 =~ ${re[duration]} ]] ||
  [[ $1 =~ ${re[duration]} && $2 == @(before|after) && $3 =~ ${re[date]} ]]
then
  range=("${@:1:3}")
  shift 3
elif
  [[ $1 == 'from' && $2 =~ ${re[date]} ]] ||
  [[ $1 =~ ${re[duration]} && $2 == 'ago' ]] ||
  [[ $1 == 'for' && $2 =~ ${re[duration]} ]]
then
  range=("${@:1:2}")
  shift 2
elif
  [[ $2 =~ ${re[date]} ]] ||
  [[ $1 =~ ${re[duration]} ]]
then
  range=("${@:1:1}")
  shift 1
fi

if [[ ${#range[@]} -eq 0 ]]; then
  if [[ ${WATCHTOWER_SCRIPT[watch]} ]]; then
    range=("$((LINES - 5))d" 'before' 'tomorrow')
  else
    range=("$(timew summary :all | sed -En '4 { s/^([^@]*) @.*$/\1/p; q }')" 'to' 'now')
  fi
fi

declare -A width

width[left]=15
width[right]=7
width[middle]=$(( COLUMNS - width[left] - width[right] ))
width[hour]=$(( width[middle] / 24 ))

declare -- cell=$(( 60 / ( width[hour] - 1 ) ))

timew \
  ':nocolor' ${WATCHTOWER_SCRIPT[color]:+':color'} \
  'rc.reports.week.lines=1' \
  "rc.reports.week.cell=$cell" \
  'rc.reports.week.week=yes' \
  'rc.reports.week.month=yes' \
  'rc.reports.week.holidays=no' \
  'rc.reports.week.summary=no' \
  'week' \
  "${range[@]}" "${@@Q}" |

  sed -E 's/(\x1b\[30;)107(m)/\147\2/g'
