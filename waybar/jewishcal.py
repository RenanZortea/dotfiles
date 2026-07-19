#!/usr/bin/env python3
"""Waybar custom module: Hebrew (Jewish) calendar.
Prints JSON: bar text = short Hebrew date, tooltip = full info + upcoming holidays.
Uses the hdate library in the isolated venv (see shebang override in modules.json)."""
import datetime
import json
import sys

from hdate import HDateInfo
from hdate.translator import set_language

set_language("en")
DIASPORA = True  # Ribeirao Preto, Brazil -> diaspora observance


def line(d):
    info = HDateInfo(d, diaspora=DIASPORA)
    hd = info.hdate
    short = f"{hd.day} {hd.month}"          # e.g. "5 Av"
    full = str(info)                         # e.g. "Sunday 5 Av 5786"
    hols = [str(h) for h in info.holidays]
    return info, hd, short, full, hols


def main():
    today = datetime.date.today()
    info, hd, short, full, hols = line(today)

    # Tooltip: today's full date, parasha, today's holidays, then scan ahead.
    tip = [f"<b>{full}</b>"]
    if info.parasha and str(info.parasha) not in ("none", "None", ""):
        tip.append(f"Parasha: {info.parasha}")
    if hols:
        tip.append("Today: " + ", ".join(hols))
    if info.omer and getattr(info.omer, "total_days", 0):
        tip.append(f"Omer: day {info.omer.total_days}")

    upcoming = []
    for i in range(1, 60):
        d = today + datetime.timedelta(days=i)
        hi = HDateInfo(d, diaspora=DIASPORA)
        for h in hi.holidays:
            upcoming.append((d, str(h)))
        if len(upcoming) >= 4:
            break
    if upcoming:
        tip.append("")
        tip.append("<b>Upcoming:</b>")
        for d, name in upcoming[:4]:
            days = (d - today).days
            tip.append(f"{d:%b %d} ({days}d) — {name}")

    text = "✡ " + short  # ✡ + "5 Av"
    print(json.dumps({"text": text, "tooltip": "\n".join(tip), "class": "jewishcal"}))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(json.dumps({"text": "✡ ?", "tooltip": f"jewishcal error: {e}"}))
        sys.exit(0)
