# Bus

bus is a bullshit-free transit information utility for the Greater Dublin area. Fetch real time information, stop locations, route information for Dublin Bus, Bus Éireann, Iarnród Éireann and LUAS, without leaving the command line.

* bus happily depends on [jq](http://stedolan.github.io/jq)
* RTPI API access is required, [contact Transport for Ireland](http://www.transportforireland.ie/contact/) to request a set of credentials.

## Usage
```
usage:
    bus <stop id> [route id]
    bus <action> [args]

actions:
    search <query> [-g]
    info <stop id>
    stops <route id> [db|be|ir|luas]
```

### Real Time Passenger Information
If you know your stop ID, `bus <stopid>` will emulate that stop's amber-LED sign:

```
$ bus 1279
83   Kimmage               Due
150  Rossmore              Due
54A  Kiltipper           11min
    ...
83   Kimmage             55min
Trinity Street     Time: 10:10

```
You can filter by route with the optional `routeid` argument:
```
$ bus 1279 83
83   Kimmage             34min
83   Kimmage             54min
Trinity Street     Time: 10:10
```

### Stop Information
`bus info <stopid>` gives a detailed description of `<stopid>`

```
$ bus info 1279
Trinity Street College Green
Dublin Bus serving routes [54A, 83A, 83, 16, 150]
http://osm.org/?mlat=53.344256&mlon=-6.261685#map=17/53.344256/-6.261685
```

### Stop Search
If you *don't* know your stop ID, `bus search <query>` will return a list of all stops whose name contains `<query>`. Add the `-g` flag to search through Gaeilge, though not all stops have been translated:

```
$ bus search Trinity
1279    db  College Green, Trinity Street
300401  be  Wexford , Wexford (Trinity St Opposite Centra)
    ...
7456    db  College Green, Opposite Trinity College
```
The second column is the operator code: `db` for Dublin Bus, `BE` for Bus Éireann, `ir` for Iarnród Éireann, and the self-explanatory `LUAS`.

### Route Information
`bus route <routeid> <operator code>` will (again, rather unweildly) list *all* stops served by `<operator code>`'s `<routeid>` in the specified direction

```
$ bus route 83 db
Harristown to Kimmage
    ...
Kimmage to Harristown
Which route? (1|2|3...): 1

2492  Stannaway Court            Stannaway Ave
2493  Captain's Avenue           Captain's Road
    ...
332   Bus Garage                 Harristown
7131  Charlestown S.C.           Charlestown Rd
```

## Disclaimers
* I mainly wrote bus to get more proficient in writing both shell and jq filters; it's a little rough around the edges, so don't blame me if you miss your bus!

* bus is unofficial and unsanctioned by TFI/Dublin Bus/Bus Éireann/Iarnród Éireann/Luas etc. 

* To use the RTPI API, you must agree to the terms of the [PSI General Licence](http://psi.gov.ie/files/2010/03/PSI-Licence.pdf).
