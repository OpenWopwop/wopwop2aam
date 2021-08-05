# wopwop2aam

wopwop2aam is a utility used to convert an OpenWopwop observer sphere grid to an AAM compatible netCDF sphere.

## Dependencies

wopwop2aam depends on wopwopd, a support library for reading and writing OpenWopwop input files. To install, run:
```
git submodule update --init --recursive
```

It also depends on netCDF. One can either install this from source, or a package manager if available.

## Building
wopwop2aam is written in D and uses D's build system dub. The easiest way to build is
```
dub build -b release
```

For more performance (not that it's terribly important for this) one can use the ldc D compiler
```
dub build -b release --compiler=ldc2
```

## Running

wopwop2aam takes in 5 arguments: a namelist, a flight path angle, and tilt angle, a speed, and an output file name. Flight path angle and tilt angle are specified in degrees, and speed is specified in knots. An example that creates an AAM sphere with a flight path angle of 0 degrees, a nacelle tilt angle of 1 degrees and a speed of 2 knots:
```
./wopwop2aam -n example_namelist.nam -f 0 -t 1 -s 2 -o aam_sphere.nc
```
