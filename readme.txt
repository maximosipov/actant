Actant - Activity Analysis Toolbox

1. Data formats
===============

Actant reads data in Actiwatch, GENEActiv and Actopsy app (CSV) formats.
Internally, all the data is represented as Matlab timeseries objects with
the following names:

  ACC - 3D accelerometry data (m/s^2 or g)
  ACT - activity data (counts or m/s^2 or g)
  LIGHT - light data (lux)
  TEMP - temperature data (degC)
  BUTTON - button press indicators (binary)

Plus, in future:

  GYRO - 3D gyroscope (deg)
  HUM - humidity (%)
  PRES - atmospheric pressure (mbar)
  HR - heart rate (bpm)

Additionally, markup timeseries can be generated using analysis algorithms,
where time vector represents starting points of marked intervals and data
vector represents end points (as datenum).

  <ANY> - markup data (days)

For unification of data analysis, all high-dimensional and high-sampling
rate activity data can be converted to epochs, either Actiwatch compatible
(counts) or as average acceleration per epoch (m/s^2).

2. Analysis methods
===================

Analysis methods may generate scalar values, timeseries with values or
timeseries with data markup. For example, non-linear activity analysis will
generate L5, M10, RA, IS and IV values plus timeseries with segmentations
of L5 and M10. Windowed spectral analysis will generate timeseries with
spectral content of analyzed signal.

The API of analysis method is as following:

function [ts, markup, vals] = actant_analysis(data, args)
  Arguments:
    data - Input data timeseries
    args - Cell array of arguments

  Results (all optional):
    ts - Structure of timeseries
    markup - Structure of data markups
    vals - Cell array of results

When function called without arguments, array of function arguments and
default values is returned in vals, where the first element of array is '_'
with the name of the analysis method as value.


3. Visualization
================

The main plot is N days activity plot and can be overlapped with additional
plot (YY axis, result of windowed analysis) and with markup (transparent
patches, result of segmentation).

The plot is configurable with a number of plots to display, number of days
per plot and overlap between plots (in days), so that both single day plots
can be displayed with N-1-0 and 48 hours actogram with N-2-1 settings.
