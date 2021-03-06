get.NIDitem <- function(item, name) {
  n0 = grep(paste0(name,'='),item)
  gsub(paste0(name,'='),'',item[n0])
}

get.NIDitem.numeric <- function(item, name) {
  n0 = grep(paste0(name,'='),item)
  as.numeric(gsub(paste0(name,'='),'',item[n0]))
}

#' returns the scales of a particular channel / image
#'
#' @param headerList header list as obtained from read.NID_headerItems
#' @param imageNo 1,2,3,4 denoting the number of the image
#' @return data.frame with scales for (x,y,z)
#' @examples
#' filename = dir(pattern='nid$', recursive=TRUE)[1]
#' h=read.NID_headerItems(filename)
#' NID.getChannelScale(h,1)
#' @export
NID.getChannelScale <- function(headerList, imageNo = 1) {
  c1 = switch(imageNo, "Gr0-Ch1","Gr0-Ch2","Gr1-Ch1","Gr1-Ch2",
              "Gr2-Ch1","Gr2-Ch2","Gr3-Ch1","Gr3-Ch2")
  d.set = get.NIDitem(headerList[[2]],c1)
  k.set = grep(d.set,headerList[[1]])
  h = headerList[[k.set]]

  ax=data.frame(axis='x',units = get.NIDitem(h,'Dim0Unit'),
          from=get.NIDitem.numeric(h,'Dim0Min'),
          to=get.NIDitem.numeric(h,'Dim0Min')+get.NIDitem.numeric(h,'Dim0Range'),
          length=get.NIDitem.numeric(h,'Points'))
  ay=data.frame(axis='y',units = get.NIDitem(h,'Dim1Unit'),
          from=get.NIDitem.numeric(h,'Dim1Min'),
          to=get.NIDitem.numeric(h,'Dim1Min')+get.NIDitem.numeric(h,'Dim1Range'),
          length=get.NIDitem.numeric(h,'Lines'))
  az=data.frame(axis='z',units = get.NIDitem(h,'Dim2Unit'),
          from=get.NIDitem.numeric(h,'Dim2Min'),
          to=get.NIDitem.numeric(h,'Dim2Min')+get.NIDitem.numeric(h,'Dim2Range'),
          length=2**get.NIDitem.numeric(h,'SaveBits'))
  rbind(ax,ay,az)
}
