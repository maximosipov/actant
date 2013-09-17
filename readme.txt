Actant - Activity Analysis Toolbox

1. Data formats
===============

Actant reads data in Actiwatch, GENEActiv and Actopsy app (CSV) formats.
Internally, all the data is represented as Matlab timeseries objects with
the following names:

  ACC - 3D accelerometry data (m/s^2)
  ACT - activity data (counts or m/s^2)

Plus, in future:

  GYRO - 3D gyroscope (deg)
  LIGHT - light data (lux)
  TEMP - temperature data (degC)
  HUM - humidity (%)
  PRES - atmospheric pressure (mbar)
  HR - heart rate (bpm)

Additionally, markup timeseries can be generated using analysis algorithms,
where time vector represents starting points of marked intervals and data
vector represents end points (as datenum).

  MARKUP - markup data (days)

For unification of data analysis, all high-dimensional and high-sampling
rate activity data can be converted to 1 minute epochs, either Actiwatch
compatible (counts) or as average acceleration per epoch (m/s^2).

2. Analysis methods
===================

Analysis methods may generate scalar values, timeseries with values or
timeseries with data markup. For example, non-linear activity analysis will
generate L5, M10, RA, IS and IV values plus timeseries with segmentations
of L5 and M10. Windowed spectral analysis will generate timeseries with
spectral content of analyzed signal.

3. Visualization
================

The main plot is 24(48) hours activity plot and can be overlapped with
additional plot (YY axis, result of windowed analysis) and with markup
(transparent patches, result of segmentation).

Visualization will include two plots - one at the top with a complete data
and on the right with selected days. Values for number of days to display
on the left panel and Y range are configurable below the panel.

(should I use a single plot and add Y offset as with ECG Matlab project?)
