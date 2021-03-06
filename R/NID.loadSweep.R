#' loads frequency sweep data from NID file
#'
#' @param filename filename including path
#' @return data.frame with data frames that have freq vs. ampl.
#' @examples
#' filename = dir(pattern='nid$', recursive=TRUE)[1]
#' d = NID.loadSweep(filename)
#' @export
NID.loadSweep <- function(filename) {
  # read header file and find length
  h = read.NID_headerItems(filename)
  d.set = get.NIDitem(h[[2]],'Gr0-Ch2')
  k.set = grep(d.set, h[[1]])
  k1 = h[[k.set]]
  freq.min = get.NIDitem.numeric(k1,'Dim0Min')
  freq.range = get.NIDitem.numeric(k1,'Dim0Range')
  freq.len = get.NIDitem.numeric(k1,'Points')
  A.min = get.NIDitem.numeric(k1,'Dim2Min')
  A.range = get.NIDitem.numeric(k1,'Dim2Range')
  A.len = 2**get.NIDitem.numeric(k1,'SaveBits')

  # read header
  h = read.NID_header(filename)
  header.length = h[[1]]
  con <- file(filename,"rb")
  bin.header <- readBin(con, integer(),  n = header.length, size=1, endian = "little")
  bin.ID = readBin(con, integer(),  n = 2, size=1, endian = "little")
  #r = list(header = bin.header, ID = bin.ID)
  r = data.frame()

  if (sum(bin.ID) == sum(c(35,33))) {
    if(freq.len>0) {
        bin.data <- readBin(con, integer(),  n = freq.len, size=2, endian = "little")
        r = data.frame(Freq.Hz = seq(from=freq.min, to=freq.min + freq.range, length.out=freq.len),
                            Amplitude.V = (bin.data*A.range/A.len) + A.min)
    }
  }
  close(con)
  r
}
