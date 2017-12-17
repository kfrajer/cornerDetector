## cornerDetector

<h1 align="center">
    <img src="./cornerDetector/SampleResults/v2_allCorners_DisplayFalse.png.png" alt="logo" width="300">
  <br>
</h1>

## Overview

Finds all the corners and intercepts in a binary image. The basic algorithm is based on applying a window around a point of interest. Then it calculates the pixel integrals (from the image's blue channel) from the bin center to the edge of the window, a window w/2-1 number of bins, where w is the width of the selected window. These produces 4 summations: N, S, E, W. Testing for this summations allows to choose what points belong to a corner. 

This is a demo that requires further optimization and improvement. 

## Requirements

The image is required to be of binary type (use [Threshold filter](https://processing.org/reference/PImage_filter_.html) from PImage) and lines are expected to have any width. However, if the lines involved have a thickness different to 1 then the algorithm returns an area corresponding to the interception.

## Instructions

There are two veersions within the code. Version 1 (activated using key '1') is a dynamic display of any corner detected. It works for corners but it fails for T and cross intercepts (line over line). Version 2 (access using either key '2' or '9') provides an algorithm that detects corners and intercepts. Use key 9 to show all intercepts on image, or 2 for a dynamic showcase using the mouse. In this case, it shows the examination window (in green), and a red circle anywhere where an intercept is found.

Load your binary image and then select the window size to operate, which defines a square region to apply the algorithm on. Notice the size of the window will affect the behavior of the algorithm in the edges of the sketch, as those regions in the sketch will be ignored. A window of any size larger than 5 should work for lines of thickness 1. For line of thickness 10, for instance, use a window size of 20 or 30.

## Bugs and Issues

Any suggestions or comments, please comment in the [issue section](https://github.com/kfrajer/cornerDetector/issues) of this GitHub.

## Creator

TBC

## Copyright and License

TBC
