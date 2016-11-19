# bus

Minimal real time information for Dublin Bus.

## Usage
```
$ bus 1294
54A  Pearse St  7
150  Fleet St   8
150  Fleet St   27
54A  Pearse St  36
150  Fleet St   47
```

Top tip: The Luas stops have stop IDs like all of the bus stations, `LUAS<X>`, e.g.:

```
$ bus LUAS29
Green  LUAS St. Stephen's Green  3
Green  LUAS Bride's Glen         4
Green  LUAS St. Stephen's Green  9
Green  LUAS Sandyford            10
Green  LUAS St. Stephen's Green  15
Green  LUAS St. Stephen's Green  17
```

So do the train stations, but I never really take trains.

_Anther top tip_: combine with `watch`, as in `watch --no-tile -n 30 bus LUAS12` for an updating realtime display.
