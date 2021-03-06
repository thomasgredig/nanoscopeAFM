# nanoscopeAFM

Analyzes Atomic Force Microsocpy (AFM) images from Nanosurf (.nid) or Veeco Multimode Nanoscope III.


## Installation

```R
# install.packages("devtools")
devtools::install_github("thomasgredig/nanoscopeAFM")
```

## Description

The main functions from this library are:

- **read.AFM_file**: loads the AFM image as a matrix and includes attributes

More specialized functions from the library:

- **NID.checkFile**: should return 0
- **NID.loadImage**: loads an NID image
- **NID.loadSweep**: Frequency Sweep NID file
- **read.NID_header**: reads the header of a NID file
- **read.NID_file**: read the images from a NID file
- **flatten.NID_matrix**: plane fit to remove background
- **get.NIDchannel.Scale**: returns scales of image

# AFM Images

Loading an AFM image into memory works as follows:

```R
fname = 'image.ibw' # Igor Wavefile, NID file
d = read.AFM_file(fname)
```

The attributes can be viewed with `str(d)` and include units. The conversion from line to distance is made with the `attr(d, "convFactor")` factor. The image is usually displayed as follows:

```R
library(ggplot2)
library(scales)

ggplot(d, aes(x.nm, y.nm, fill = z.nm)) + 
  geom_raster() +
  scale_fill_gradient2(mid='white', high=muted('purple')) +
  xlab(expression(paste('x (',mu,'m)'))) +
  ylab(expression(paste('y (',mu,'m)'))) +
  labs(fill='z (nm)') +
  scale_y_continuous(expand=c(0,0))+
  scale_x_continuous(expand=c(0,0))+
  coord_equal() +
  theme_bw()
```

A cross-section of the image can now easily be created:

```R
LINE.NO = 45
d1 = subset(d, y==LINE.NO)
ggplot(d1, aes(x.nm, z.nm)) +
  geom_path(col='black') + 
  geom_point(col='red', size=2) + 
  geom_point(col='white', size=1)+ 
  scale_x_continuous(breaks=0:20*0.2) + 
  xlab(expression(paste('x (',mu,'m)'))) +
  ylab('z (nm)') + 
  theme_bw()
```

# NanoSurf Images


The image can be loaded into memory using `NID.loadImage` command using a filename and the image number. The image is automatically flattened and contains both the original measurement (z) as well as the flattened image (z.flatten); so here is an example:

```R
library(nanoscopeAFM)
library(ggplot2)
fname = dir(pattern='nid$', recursive = TRUE)
d = NID.loadImage(fname[2],1)

ggplot(d, aes(x*1e6,y*1e6, fill=z.flatten*1e9)) +
    geom_raster() +
    xlab(expression(paste('x (',mu,'m)'))) +
    ylab(expression(paste('y (',mu,'m)'))) +
    labs(fill='z (nm)') +
    scale_y_continuous(expand=c(0,0))+
    scale_x_continuous(expand=c(0,0))+
    theme_bw()
```    

The first image is usually a topography channel (z-axis, units of meters) and the second image maybe the cantilever amplitude in units of voltage.

![Rastered image after flattening](images/CalibrationGrid.png)


## Image Analysis

Histogram can be used to study the roughness or height levels:

```R
# make a histogram
ggplot(d, aes(x=z.flatten)) +
    geom_histogram(aes(y=..density..),
    colour="black", fill="white", bins=200)+
    geom_density(alpha=0.2, fill='red')
```

![histogram example](images/CalibrationGrid-Histogram.png)


You may need to perform additional image analysis, for example you may want to remove the background. This can be performed with this code:

```R
library(raster)
m1 = flatten.NID_matrix(m)
plot(raster(m1))
```
![sample output from code above](images/Calibration-NID-File.Flattened.png)


## Frequency Sweep

If the NID file is a frequency sweep, you can display the data using the function `NID.loadSweep` which will return a list that contains data frames with the frequency vs. amplitude data.

```R
q = NID.loadSweep(fname[1])
plot(q[[1]],xlab='f (Hz)', ylab='A')
```

![sample output for frequency sweep](images/Frequency-Sweep.png)

The units for amplitude are stored in the header of the file and can be modified accordingly.


## Line Profile

Using the [Bresenham algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm), the pixel locations along a profile line are computed.


```R
# d is populated with NID.loadImage()
q = NID.lineProfile(d, 0,0,2e-6,2e-6)
d2 = d[q,]
d2$distance = sqrt(d$x*d$x+d$y*d$y)
# plot the line profile
plot(d2$distance, d2$z.flatten)
```

# Nanoscope AFM images


Similar functions are available for Nanoscope files

```R
fname = dir(pattern='\\.\\d+$', recursive = TRUE)
for(f in fname) {
    d = read.Nanoscope_file(f)
    bin.data = d[[1]]
    library(raster)
    m = matrix(bin.data, nrow=sqrt(length(bin.data)))
    plot(raster(m))
}
```

For header information, you can run:

```R
h = read.Nanoscope_header(f)
```

Convert and save all files in folder to PNG format
```R
# find the files
file.list = raw.findFiles(path.RAW, date='2016', instrument='afm')
file.list = file.list[grep('\\d{3}$',file.list)]

# save the first image of each AFM file
for(f in file.list) {
  d= read.Nanoscope_file_scaled(f)
  ggplot() +
    geom_raster(data = d , aes(x = x, y = y, fill = z)) +
    coord_equal(expand=FALSE) +
    xlab('x (nm)') +
    ylab('y (nm)') +
    scale_fill_continuous(name='z (nm)') +
    ggtitle(f)
  filename.png = gsub(str_extract(f, pattern = '\\..{3}$'),'.png',f)
  ggsave(file.path('',filename.png), dpi=300)
}
```

# Technical Notes

The [least significant bit (LSB)](https://masteringelectronicsdesign.com/an-adc-and-dac-least-significant-bit-lsb/) provides the smallest voltage step, given the 16-bit resolution of the NanoScope AFM, then Vref = 2^16*LSB.




The [header file](http://www.weizmann.ac.il/Chemical_Research_Support/surflab/peter/headers/) is documented for versions 2,3, and 4. [Z-scaling Info](https://bioafm.physics.leidenuniv.nl/dokuwiki/lib/exe/fetch.php?media=afm:nanoscope_software_8.10_user_guide-d_004-1025-000_.pdf)
