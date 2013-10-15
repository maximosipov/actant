Actant - Activity Analysis Toolbox

Copyright (C) 2013, Maxim Osipov <maxim.osipov@gmail.com>
Copyright (C) 2013, Bart te Lindert <b.te.lindert@nin.knaw.nl>

This toolbox include multiple data analysis algorithms implemented in
Matlab and released under Open Source licences. Respective licences are
referenced directly in the code of specific Matlab functions.

0. About
========

Actant provides functionality for visualization and analysis of behavioral
and environmental timeseries, acquired using Actiwatch-L and GENEActiv
accelerometers as well as Actopsy mobile application. Currently implemented
analysis methods include:

 - Non-parametric activity analysis: Van Someren, Eus JW, et al. "Bright
   light therapy: improved sensitivity to its effects on rest-activity
   rhythms in Alzheimer patients by application of nonparametric methods."
   Chronobiology international 16.4 (1999): 505-518.

 - Sleep analysis: Reference here

 - Sample Entropy: Richman, Joshua S., and J. Randall Moorman.
   "Physiological time-series analysis using approximate entropy and sample
   entropy." American Journal of Physiology-Heart and Circulatory
   Physiology 278.6 (2000): H2039-H2049.

 - Multiscale Entropy: Costa, Madalena, Ary L. Goldberger, and C-K. Peng.
   "Multiscale entropy analysis of complex physiologic time series."
   Physical review letters 89.6 (2002): 068102.

The toolbox provides flexible interface for integration of both new data
formats and analysis methods. 

1. Data formats
===============

Actant reads data in Actiwatch, GENEActiv, Actopsy app (CSV) and Actant
own (MAT) formats. Internally, all datasets represented as Matlab
timeseries objects with the following names:

  ACC - 3D accelerometry data (m/s^2 or g)
  ACT - activity data (counts or m/s^2 or g)
  LIGHT - light data (lux)
  TEMP - temperature data (degC)
  BUTTON - button press indicators (binary)
  SPEED - distance travelled (km/h, inaccurate depending on location)
  TEXTS - sms messages (days, each character counted as second)
  CALLS - phone calls (days)

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

Actant MAT format includes Matlab variables to initialize Actant internal
state, including datasets, analysis algorithm and results:

  datasets - array of timeseries objects for datasets
  files - array of filenames for 'datasets'
  analysis
    method - analysis method name
    arguments - method arguments
    results - results of analysis (except timeseries)

2. Analysis methods
===================

Analysis methods may generate scalar values and timeseries (with values or
data markup). For example, non-linear activity analysis will generate L5,
M10, RA, IS and IV values plus timeseries with segmentations of L5 and M10.
Windowed spectral analysis will generate timeseries with spectral content
of analyzed signal.

The API of analysis method is as following:

function [ts vals] = actant_analysis(data, args)
  Arguments:
    data - Input data timeseries
    args - Cell array of arguments

  Results (all optional):
    ts - Structure of timeseries
    vals - Cell array of results

When method called without arguments, array of function arguments and
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

4. Contributions
================

Authors would appreciate your contributions to the Actant project (code can
be found at https://github.com/maximosipov/actant). Also, you are invited
to contrubute your datasets to Physionet (http://www.physionet.org/).
