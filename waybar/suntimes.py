#!/usr/bin/env python3
"""Waybar custom module: sunrise / sunset for Ribeirao Preto.

Arg selects what to print:
  sunrise    -> "☀ <time>"   sunset -> "☾ <time>"   (time formatted in the
               CURRENTLY selected clock mode, read from hexclock.mode)
  countdown  -> "<icon> <Hh Mm>" until the next event (legacy single-chip)

The <time> is kept in sync with the scrollable clock: it uses the same mode
list/order as hexclock.sh, reading the shared state file so scrolling the clock
reformats these too (they refresh on SIGRTMIN+8)."""
import datetime
import json
import os
import sys
from zoneinfo import ZoneInfo

from hdate import Zmanim, Location

TZ = ZoneInfo("America/Sao_Paulo")
UTC = ZoneInfo("UTC")
STATE = os.path.expanduser("~/.config/waybar/hexclock.mode")
MODES = ["hexfield", "normal", "hextime", "unix", "beats"]  # must match hexclock.sh

LOC = Location(
    name="Ribeirao Preto",
    latitude=-21.1767,
    longitude=-47.8208,
    timezone="America/Sao_Paulo",
    altitude=546,
    diaspora=True,
)


def current_mode():
    try:
        idx = int(open(STATE).read().strip())
    except Exception:
        idx = 0
    return MODES[idx % len(MODES)]


def fmt(dt, mode):
    """Format an aware local datetime in the given clock mode."""
    if mode == "normal":
        return dt.strftime("%H:%M")
    if mode == "hexfield":
        return f"{dt.hour:02X}:{dt.minute:02X}"
    if mode == "hextime":
        secs = dt.hour * 3600 + dt.minute * 60 + dt.second
        return f".{secs * 65536 // 86400:04X}"
    if mode == "unix":
        return str(int(dt.timestamp()))
    if mode == "beats":
        u = dt.astimezone(UTC)
        secs = (u.hour * 3600 + u.minute * 60 + u.second + 3600) % 86400
        return f"@{secs * 1000 // 86400:03d}"
    return dt.strftime("%H:%M")


def sun(d):
    z = Zmanim(date=d, location=LOC)
    return z.zmanim["netz_hachama"].local, z.zmanim["shkia"].local


def fmt_delta(td):
    m = int(td.total_seconds() // 60)
    h, m = divmod(m, 60)
    return f"{h}h{m:02d}m" if h else f"{m}m"


def tooltip(rise, set_, now):
    daylight = set_ - rise
    if now < rise:
        nxt = f"sunrise in {fmt_delta(rise - now)}"
    elif now < set_:
        nxt = f"sunset in {fmt_delta(set_ - now)}"
    else:
        r2, _ = sun(now.date() + datetime.timedelta(days=1))
        nxt = f"sunrise in {fmt_delta(r2 - now)}"
    return "\n".join([
        "<b>Ribeirão Preto</b>",
        f"☀ Sunrise  {rise:%H:%M}",
        f"☾ Sunset   {set_:%H:%M}",
        f"· Daylight {fmt_delta(daylight)}",
        f"→ next {nxt}",
    ])


def main():
    arg = sys.argv[1] if len(sys.argv) > 1 else "countdown"
    now = datetime.datetime.now(TZ)
    today = now.date()
    rise, set_ = sun(today)
    mode = current_mode()
    tip = tooltip(rise, set_, now)

    if arg == "sunrise":
        out = {"text": f"☀ {fmt(rise, mode)}", "tooltip": tip, "class": "sunrise"}
    elif arg == "sunset":
        out = {"text": f"☾ {fmt(set_, mode)}", "tooltip": tip, "class": "sunset"}
    else:  # countdown
        if now < rise:
            icon, target = "☾", rise
        elif now < set_:
            icon, target = "☀", set_
        else:
            r2, _ = sun(today + datetime.timedelta(days=1))
            icon, target = "☾", r2
        out = {"text": f"{icon} {fmt_delta(target - now)}", "tooltip": tip, "class": "suntimes"}
    print(json.dumps(out))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(json.dumps({"text": "☀ ?", "tooltip": f"suntimes error: {e}"}))
        sys.exit(0)
