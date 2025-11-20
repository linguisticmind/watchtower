# timew-summary.bash - display a Timewarrior summary table report
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

declare -A sed_script

IFS= read -rd '' 'sed_script[1]' <<- 'EOF'
	1 d; 2 { h; d }; 3 { H; G; x; s/^.*\n//; x };
	$ ! {
	  /^\s*$/ {
	    N
	    /^\s*[[:digit:]:]+$/ {
	      s/^.*\n//
	      x; G
	    }
	  }
	}
	$ d
EOF

IFS= read -rd '' 'sed_script[2]' <<- EOF
	3 { h; d }
	4 {
	  :a \$ ! { N; b a }
	  x; G
	  s/'/'\\\\''/g
	  s/.*/t="\$(printf '%s' '&')" s="\${t%%\\n*}\\n" t="\${t#*\\n}\\n" n="\$(printf '%s' "\$t" | wc -l)" m="\$(($LINES - 3))"; test "\$n" -le "\$m" \\&\\& printf '%s' "\$s" || printf '%s' "\$s" | sed "s\\/-\\/^\\/g"; printf '%s' "\$t" | tail -n "\$m"/e
	}
EOF

timew \
  'rc.reports.summary.range=all' \
  'rc.reports.summary.ids=yes' \
  'rc.reports.summary.annotations=yes' \
  'rc.reports.summary.weeks=no' \
  'rc.reports.summary.weekdays=no' \
  'rc.reports.summary.holidays=no' \
  summary "$@" |
    sed -E "${sed_script[1]}" |
    if [[ ${WATCHTOWER_SCRIPT[watch]} ]]; then sed -E "${sed_script[2]}"; else cat; fi

# vim: set list listchars=tab\:␉· tabstop=2 :
