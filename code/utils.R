### Just a paste, but with 1) shorter name and 2) no space as separator
p <- function(...) {
    return(paste(..., sep=''))
}


### If values of v are not contained inside the BBox defined by min &
### man, then truncate the too big values
###### TODO: does not work if v contains NAs
confine <- function(v, minn, maxx) {
    v[v<=minn] <- minn[v<=minn]
    v[v>=maxx] <- maxx[v>=maxx]
    return(v)
}
