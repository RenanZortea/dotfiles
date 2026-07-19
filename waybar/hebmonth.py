#!/usr/bin/env python3
"""Emit Hebrew-calendar overlay data for the Quickshell month grid.

Args: <year> <month0>   (month0 is 0-based, matching QML's currentMonth)

Output (JSON): {
  "header": "Av–Elul 5786",           # Hebrew month(s) spanning this Gregorian month
  "cells":  [ {"d": "5", "hol": false}, ... 42 entries ]  # Monday-first grid order
}
The 42 cells match CalendarWindow.qml's grid exactly: start = 1st of month
backed up to the Monday of its week, then 42 consecutive days."""
import datetime
import json
import sys

from hdate import HDateInfo
from hdate.translator import set_language

set_language("en")
DIASPORA = True


def main():
    year = int(sys.argv[1])
    month0 = int(sys.argv[2])
    month = month0 + 1  # python months are 1-based

    first = datetime.date(year, month, 1)
    start = first - datetime.timedelta(days=first.weekday())  # Monday-first

    cells = []
    for i in range(42):
        d = start + datetime.timedelta(days=i)
        info = HDateInfo(d, diaspora=DIASPORA)
        cells.append({"d": str(info.hdate.day), "hol": bool(info.holidays)})

    # header: Hebrew month(s) covering this Gregorian month
    last = datetime.date(year, month, 1)
    if month == 12:
        last = datetime.date(year + 1, 1, 1) - datetime.timedelta(days=1)
    else:
        last = datetime.date(year, month + 1, 1) - datetime.timedelta(days=1)
    hm_first = HDateInfo(first, diaspora=DIASPORA).hdate
    hm_last = HDateInfo(last, diaspora=DIASPORA).hdate
    if str(hm_first.month) == str(hm_last.month):
        header = f"{hm_first.month} {hm_first.year}"
    elif hm_first.year == hm_last.year:
        header = f"{hm_first.month}–{hm_last.month} {hm_last.year}"
    else:
        header = f"{hm_first.month} {hm_first.year} – {hm_last.month} {hm_last.year}"

    print(json.dumps({"header": header, "cells": cells}))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(json.dumps({"header": "", "cells": [], "error": str(e)}))
