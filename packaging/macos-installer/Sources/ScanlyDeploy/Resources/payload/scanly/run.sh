#!/bin/sh
set -eu

cd /home/root/xovi/exthome/appload/scanly

# Qt's linuxfb plugin checks that the framebuffer path exists before calling
# open(). Paper Pro has no real /dev/fb0, but qtfb-shim hooks that exact path.
if [ ! -e /dev/fb0 ]; then
    ln -s /dev/null /dev/fb0
fi

# Always start the app chrome in a visible mode. ReaderPage may switch this
# while it is open, then resets it on exit.
printf 'Content\n' > /tmp/scanly-qtfb-default-mode

export QTFB_SHIM_MODEL="${QTFB_SHIM_MODEL:-RMPP}"
export QTFB_SHIM_MODE="${QTFB_SHIM_MODE:-RGB565}"
export QTFB_SHIM_INITIAL_DISPLAY_MODE="${QTFB_SHIM_INITIAL_DISPLAY_MODE:-CONTENT}"
export QTFB_SHIM_FB="${QTFB_SHIM_FB:-1}"
export QT_QUICK_BACKEND="${QT_QUICK_BACKEND:-software}"
export LD_PRELOAD="/home/root/xovi/exthome/appload/shims/qtfb-shim.so${LD_PRELOAD:+:$LD_PRELOAD}"

exec ./scanly
