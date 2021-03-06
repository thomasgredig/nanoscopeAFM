% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.IBW_file.R
\name{read.IBW_file}
\alias{read.IBW_file}
\title{loads images}
\usage{
read.IBW_file(filename, no = 1)
}
\arguments{
\item{filename}{filename including path}

\item{no}{number of the channel}
}
\value{
image with attributes
}
\description{
loads images
}
\examples{
filename = dir(pattern='ibw$', recursive=TRUE)[1]
d = read.IBW_file(filename)
}
