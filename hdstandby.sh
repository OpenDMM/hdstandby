#!/bin/sh
#
# Copyright (c) 2016 Dream Property GmbH, Germany
#                    https://dreambox.de/
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

exec 1> /dev/console
exec 2> /dev/console

ROOTDEV=$(udevadm info -d /)

is_active()
{
	if which smartctl >/dev/null; then
		smartctl -q silent -d sat -n standby "$1"
	else
		hdparm -C "$1" | grep -q "active/idle"
	fi
}

set -- $(ls -d /sys/block/sd* 2>/dev/null)
for path; do
	eval "$(udevadm info -q property $path | grep -E '^(DEVNAME|MAJOR|MINOR)=')"

	echo "Trying to put $DEVNAME into standby using sdparm"
	sdparm --command=stop --quiet --readonly "$DEVNAME"
	if is_active "$DEVNAME"; then
		echo "Trying to put $DEVNAME into standby using hdparm"
		hdparm -qy "$DEVNAME"
		if is_active "$DEVNAME"; then
			echo "All attempts failed."
		fi
	fi

	if [ "$ROOTDEV" != "$MAJOR:$MINOR" -a -f "$path/device/delete" ]; then
		echo "Trying to unregister $DEVNAME."
		echo 1 > "$path/device/delete"
	fi
done

sleep 1
