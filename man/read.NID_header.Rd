% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.NID_header.R
\name{read.NID_header}
\alias{read.NID_header}
\title{loads header of AFM NID file}
\usage{
read.NID_header(filename)
}
\arguments{
\item{filename}{filename including path}
}
\value{
list with length in bytes and header as text
}
\description{
loads header of AFM NID file
}
\examples{
filename = dir(pattern='nid$', recursive=TRUE)[1]
read.NID_header(filename)
}
