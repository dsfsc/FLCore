# FLQuant.R - FLQuant class and methods
# FLCore/R/FLQuant.R

# Copyright 2003-2016 FLR Team. Distributed under the GPL 2 or later
# Maintainer: Iago Mosqueira, EC JRC G03

# FLQuant(missing){{{

#' @rdname FLQuant
#' @aliases FLQuant,missing-method
#' @examples
#'
#' FLQuant()
#' summary(FLQuant())

setMethod("FLQuant", signature(object="missing"),
  function(object, dim=rep(1,6), dimnames="missing", quant=NULL, units="NA",
    iter=1) {

    # no dim or dimnames
    if (missing(dim) && missing(dimnames)) {
      dim <- c(1,1,1,1,1,iter)
      dimnames <- list(quant='all', year=1, unit='unique', season='all',
        area='unique', iter=1:dim[6])
    } else if (missing(dim)) {
      # dim missing
      dimnames <- filldimnames(dimnames, iter=iter)
      dim <- as.numeric(sapply(dimnames, length))
    } else if (missing(dimnames)) {
    # dimnames missing
    dim <- c(dim, rep(1,6))[1:6]
        # but iter
        if(!missing(iter))
        dim[6] <- iter
        dimnames <- list(
            quant=if(dim[1]==1){"all"}else{1:dim[1]},
            year=1:dim[2],
            unit=if(dim[3]==1){"unique"}else{1:dim[3]},
            season=if(dim[4]==1){"all"}else{1:dim[4]},
            area=if(dim[5]==1){"unique"}else{1:dim[5]},
            iter=1:dim[6])
    } else {
        # both missing
        dim <- c(dim, rep(1,6))[1:6]
        # but iter
        if(!missing(iter))
            dim[6] <- iter
        dimnames <- filldimnames(dimnames, dim=dim, iter=iter)
    }

  flq <- new("FLQuant", array(as.numeric(NA), dim=dim, dimnames=dimnames),
    units=units)

    if (!is.null(quant))
        quant(flq) <- quant

    return(flq)
    }
)# }}}

# FLQuant(vector){{{

#' @rdname FLQuant
#' @aliases FLQuant,vector-method
#' @examples
#'
#' FLQuant(1:10)

setMethod("FLQuant", signature(object="vector"),
function(object, dim=rep(1,6), dimnames="missing", quant=NULL, units="NA", iter=1,
    fill.iter=TRUE) {
  
  # no dim or dimnames
  if (missing(dim) && missing(dimnames)) {
    dim <- c(1,length(object),1,1,1,iter)
    dimnames <- list(quant='all', year=1:length(object), unit='unique',
    season='all', area='unique', iter=seq(1,iter))
  }

  # dim missing
  else if (missing(dim)) {
    dimnames <- filldimnames(dimnames, iter=iter)
    dim <- as.numeric(sapply(dimnames, length))
  }

  # dimnames missing
  else if (missing(dimnames)) {
    dim <- c(dim, rep(1,6))[1:6]
    if(!missing(iter)) {
      dim[6] <- iter
    }
    dimnames <- list(
      quant=if(dim[1]==1){"all"}else{1:dim[1]},
      year=1:dim[2],
      unit=if(dim[3]==1){"unique"}else{1:dim[3]},
      season=if(dim[4]==1){"all"}else{1:dim[4]},
      area=if(dim[5]==1){"unique"}else{1:dim[5]},
      iter=1:dim[6])
  }
  # both provided
  else {
    dim <- c(dim, rep(1,6))[1:6]
    dimnames <- filldimnames(dimnames, dim=dim)
    if(!missing(iter)) {
      dim[6] <- iter
      dimnames <- filldimnames(dimnames, dim=dim, iter=iter)
    }
  }

  flq <- new("FLQuant", array(as.double(object), dim=dim, dimnames=dimnames),
    units=units)
  
  # Set extra iters to NA
  if(dims(flq)$iter > 1 && !fill.iter)
      flq[,,,,,2:dims(flq)$iter] <- as.numeric(NA)

  if (!is.null(quant))
    quant(flq) <- quant

  return(flq)
  }
) # }}}

# FLQuant(array){{{

#' @rdname FLQuant
#' @aliases FLQuant,array-method
#' @examples
#'
#' FLQuant(array(rnorm(9), dim=c(3,3,3)))

setMethod("FLQuant", signature(object="array"),
function(object, dim=rep(1,6), dimnames="missing", quant=NULL, units="NA",
  iter=1, fill.iter=TRUE) {

  # no dim or dimnames
  if (missing(dim) && missing(dimnames)) {
    # get dim from object and complete
    dim <- c(dim(object), rep(1,5))[1:6]
    # change dim[6] if iter is set
    if(!missing(iter))
      dim[6] <- iter
    # if object has dimnames, use then
    if(!is.null(dimnames(object))) {
      dimnames <- filldimnames(dimnames(object), dim=dim)
    }
    # otherwise create from dim
    else {
      dimnames <- list(quant=1:dim[1], year=1:dim[2], unit=1:dim[3],
      season=1:dim[4], area=1:dim[5], iter=1:dim[6])
      dimnames[which(dim==1)] <- list(quant='all', year=1, unit='unique',
      season='all', area='unique', iter='1')[which(dim==1)]
    }
  }

  # dim missing
  else if (missing(dim)) {
    if(missing(iter) && length(dim(object)) == 6)
      iter <- dim(object)[6]
    dimnames <- filldimnames(dimnames, dim=c(dim(object), rep(1,6))[1:6], iter=iter)
  # extract dim from dimnames
  dim <- c(dim(object),
    as.numeric(sapply(dimnames, length))[length(dim(object))+1:6])[1:6]
  if(!missing(iter))
    dim[6] <- iter
  }

  # dimnames missing
  else if (missing(dimnames)) {
    dim <- c(dim, rep(1,6))[1:6]
    if(!missing(iter))
      dim[6] <- iter
    # create dimnames from dim
    dimnames <- list(quant=1:dim[1], year=1:dim[2], unit=1:dim[3],
    season=1:dim[4], area=1:dim[5], iter=1:iter)
    dimnames[which(dim==1)] <- list(quant='all', year=1, unit='unique', season='all',
    area='unique', iter='1')[which(dim==1)]
  }
  
  flq <- new("FLQuant", array(as.double(object), dim=dim, dimnames=dimnames),
    units=units)

  # Set extra iters to NA, unless array has 6 dimensions
  if(dims(flq)$iter > 1 && !fill.iter)
    flq[,,,,,2:dims(flq)$iter] <- as.numeric(NA)

  if (!is.null(quant))
    quant(flq) <- quant

  return(flq)
  }
) # }}}

# FLQuant(matrix){{{

#' @rdname FLQuant
#' @aliases FLQuant,matrix-method
#' @examples
#'
#' FLQuant(matrix(rnorm(12), nrow=3, ncol=3))

setMethod("FLQuant", signature(object="matrix"),
  function(object, dim="missing", dimnames="missing", ...) {

  if(missing(dim))
    dim <- c(nrow(object), ncol(object), rep(1,5))[1:6]
  
  if(!missing(dimnames))
    return(FLQuant(array(object, dim=dim, dimnames=filldimnames(dimnames, dim=dim)), ...))

  if(!is.null(dimnames(object)) && missing(dimnames))
    return(FLQuant(array(object, dim=dim), dimnames=filldimnames(dimnames(object),
      dim=dim), ...))

  return(FLQuant(array(object, dim=dim), ...))
  }
) # }}}

# FLQuant(FLQuant){{{

#' @rdname FLQuant
#' @aliases FLQuant,FLQuant-method
#' @examples
#'
#' FLQuant(FLQuant(array(rnorm(9), dim=c(3,3,3)), units='kg'), units='t')

setMethod("FLQuant", signature(object="FLQuant"),
  function(object, quant=attributes(object)[['quant']], units=attributes(object)[['units']],
    dimnames=attributes(object)[['dimnames']], iter=dim(object)[6], fill.iter=TRUE,
    dim=attributes(object)[['dim']])
  {
    # generate dimnames
    dnames <- dimnames(object)
    dnames[names(dimnames)]   <- lapply(dimnames, as.character)

    # dim
    if(!missing(dim))
    {
      dims <- dim(object)
      if(any(dim > dims[1:length(dim)]))
        stop("resizing an object using 'dim' only allowed for trimming: use dimnames")
      dims[1:length(dim)] <- dim
      for(i in seq(length(dnames)))
      {
        dnames[[i]] <- dnames[[i]][1:dims[i]]
      }
    }

    # change iter
    if(!missing(iter))
      dnames['iter'] <- list(as.character(seq(length=iter)))

    # create empty FLQuant
    res <- FLQuant(dimnames=dnames, quant=quant, units=units)

    odnames <- dimnames(object)
    if(!missing(iter))
      odnames$iter <- seq(1, length(odnames$iter))
    if(fill.iter==TRUE)
      res[odnames[[1]][odnames[[1]]%in%dnames[[1]]],
          odnames[[2]][odnames[[2]]%in%dnames[[2]]],
          odnames[[3]][odnames[[3]]%in%dnames[[3]]],
          odnames[[4]][odnames[[4]]%in%dnames[[4]]],
          odnames[[5]][odnames[[5]]%in%dnames[[5]]],]  <-
      object[odnames[[1]][odnames[[1]]%in%dnames[[1]]],
             odnames[[2]][odnames[[2]]%in%dnames[[2]]],
             odnames[[3]][odnames[[3]]%in%dnames[[3]]],
             odnames[[4]][odnames[[4]]%in%dnames[[4]]],
             odnames[[5]][odnames[[5]]%in%dnames[[5]]],]
    else
      res[odnames[[1]][odnames[[1]]%in%dnames[[1]]],
          odnames[[2]][odnames[[2]]%in%dnames[[2]]],
          odnames[[3]][odnames[[3]]%in%dnames[[3]]],
          odnames[[4]][odnames[[4]]%in%dnames[[4]]],
          odnames[[5]][odnames[[5]]%in%dnames[[5]]],
          odnames[[6]][odnames[[6]]%in%dnames[[6]]]]  <-
      object[odnames[[1]][odnames[[1]]%in%dnames[[1]]],
             odnames[[2]][odnames[[2]]%in%dnames[[2]]],
             odnames[[3]][odnames[[3]]%in%dnames[[3]]],
             odnames[[4]][odnames[[4]]%in%dnames[[4]]],
             odnames[[5]][odnames[[5]]%in%dnames[[5]]],
             odnames[[6]][odnames[[6]]%in%dnames[[6]]]]

    # listo!
return(res)
}
)# }}}

# as.FLQuant(array){{{
setMethod("as.FLQuant", signature(x="array"),
  function(x, ...) {
    return(FLQuant(x, ...))
  }
)

setAs("array", "FLQuant", function(from)
  return(FLQuant(from)))
# }}}

# as.FLQuant(matrix){{{
setMethod("as.FLQuant", signature(x="matrix"),
  function(x, ...) {
    return(FLQuant(x, ...))
  }
)
setAs("matrix", "FLQuant", function(from)
  return(FLQuant(from)))
# }}}

# as.FLQuant(FLQuant){{{
setMethod("as.FLQuant", signature(x="FLQuant"),
  function(x, ...) {
    return(FLQuant(x, ...))
  }
)# }}}

# as.FLQuant(vector){{{
setMethod("as.FLQuant", signature(x="vector"),
function(x, ...) {
return(FLQuant(x, ...))
}
)
setAs("vector", "FLQuant", function(from)
  return(FLQuant(from)))
# }}}

# as.FLQuant(data.frame){{{
setMethod("as.FLQuant", signature(x="data.frame"),
function(x, ...)
  {

    # get data.frame names and compare
    names(x) <- tolower(names(x))
    validnames <-c("year","unit","season","area","iter","data")

    indices <- match(validnames, names(x))
    indices <- indices[!is.na(indices)]

    # get quant
    qname <- names(x)
    qname[indices] <- NA
    qname <- qname[!is.na(qname)]

    if (length(qname) > 1)
      stop("too many columns in data.frame")
    if(length(qname) == 0)
      qname <- "quant"

    # sort years if present
    if('year' %in% names(x))
      x <- x[order(x$year),]

    # check and fill up missing dimensions
    n <- dim(x)[1]
    # TODO conversion to/x factor messes up dimnames order
    em <- data.frame(quant=rep('all', n), year=rep(1,n), unit=rep('unique',n),
      season=rep('all',n), area=rep('unique',n), iter=rep(1,n), stringsAsFactors=FALSE)
    names(em)[names(em)=="quant"] <- qname

    x[,!names(x)%in%'data'] <- as.data.frame(x[,!names(x)%in%'data'],
      stringsAsFactors=FALSE)
    em[names(x)] <- x

    # create array
    flq <- tapply(em[,"data"], list(factor(x = em[,qname], levels = unique(em[,qname])),
      factor(x = em[,"year"], levels = unique(em[,"year"])),
      factor(x = em[,"unit"], levels = unique(em[,"unit"])),
      factor(x = em[,"season"], levels = unique(em[,"season"])),
      factor(x = em[,"area"], levels = unique(em[,"area"])),
      factor(x = em[,"iter"], levels = unique(em[,"iter"]))), sum)

    # fix dimnames names
    names(dimnames(flq)) <- c(qname, 'year', 'unit', 'season', 'area', 'iter')

    # create FLQuant
    flq <- FLQuant(flq, ...)

    # units
    if(!is.null(attr(x, 'units')))
      units(flq) <- attr(x, 'units')

    # fill up missing years
    if(length(dimnames(flq)[['year']]) != length(as.character(seq(dims(flq)$minyear,
      dims(flq)$maxyear))))
    {
      res <- FLQuant(dimnames=c(dimnames(flq)[1], list(year=seq(dims(flq)$minyear,
        dims(flq)$maxyear)), dimnames(flq)[3:6]), ...)
      res[,dimnames(flq)[['year']],] <- flq
      flq <- res
    }
return(flq)
  }
) # }}}

# dimnames<-       {{{
setMethod("dimnames<-", signature(x="FLQuant", value='list'),
  function(x, value) {

    if(length(names(value)[!names(value)%in%c("year","unit","season","area","iter")]) > 1)
      stop("more than one vector of names given for the first dimension")

    xnames <- dimnames(x)

    for(i in 1:length(value)) {
      if(any(names(value)[i]==c("year","unit","season","area","iter")))
        xnames[[names(value)[i]]] <- value[[i]]
      else {
      xnames[[1]] <- value[[i]]
      names(xnames)[1] <- names(value)[i]
      }
    }
    attributes(x)$dimnames <- xnames

    return(x)
  }
) # }}}

# dims       {{{

#' @rdname dims
#' @aliases dims,FLQuant-method
#' @examples
#' 
#' flq <- FLQuant(rnorm(96), dim=c(3,8,1,4), quant='age')
#' dims(flq)
#' 
#' # Number of seasons
#'   dims(flq)$season
#' 
#' # Length of first dimension
#'   dims(flq)[[quant(flq)]]
#'

setMethod("dims", signature(obj="FLQuant"),
  function(obj, ...){

    names <- names(dimnames(obj))
    quant   <-  as.numeric(dim(obj)[names == quant(obj)])
    min <- suppressWarnings(as.numeric(dimnames(obj)[[quant(obj)]][1]))
    max <- suppressWarnings(as.numeric(dimnames(obj)[[quant(obj)]][length(dimnames(obj)[[quant(obj)]])]))
    year<-  as.numeric(dim(obj)[names == "year"])
    minyear <-  suppressWarnings(as.numeric(dimnames(obj)$year[1]))
    maxyear <-  suppressWarnings(as.numeric(dimnames(obj)$year[dim(obj)[names == "year"]]))
    unit<-  dim(obj)[names == "unit"]
    season  <-  dim(obj)[names == "season"]
    area <-  dim(obj)[names == "area"]
    iter <- dim(obj)[names == "iter"]
    list <- list(quant=quant, min=min, max=max, year=year, minyear=minyear,
    maxyear=maxyear, unit=unit, season=season, area=area, iter=iter)
    names(list)[1] <- quant(obj)

    return(list)
  }
)   # }}}

# is.FLQuant       {{{
is.FLQuant  <-  function(x)
return(is(x, "FLQuant"))
# }}}

# show     {{{
setMethod("show", signature(object="FLQuant"),
  function(object){
    callNextMethod()
    cat("units: ", object@units, "\n")
  }
)   # }}}

# print {{{
setMethod("print", signature(x="FLQuant"),
  function(x){
    show(x)
    invisible(x)
  }
) # }}}

# totals {{{
setMethod('quantTotals', signature(x='FLQuant'),
  function(x, na.rm=TRUE) {
    sums <- x
    for (i in 1:dim(x)[2])
      sums[,i,,,,] <- rowSums(x, na.rm=na.rm, dims=1)
    return(sums)
  }
)

setMethod('yearTotals', signature(x='FLQuant'),
  function(x, na.rm=TRUE) {
    sums <- x
    for (i in 1:dim(x)[1])
      sums[i,,,,] <- colSums(x, na.rm=na.rm)[,1,1,1,1]
    return(sums)
  }
) # }}}

# sums         {{{

#' @rdname dimSummaries
#' @aliases quantSums,FLQuant-method
setMethod('quantSums', signature(x='FLQuant'), function(x, na.rm=TRUE) {

  res <- colSums(x, na.rm=na.rm)
  dim(res) <- c(1, dim(res))

  # FIX all NAs
  if(na.rm & any(res == 0)) {
    z <- is.na(x)
    y <- colSums(z) == dim(x)[1]
    res[y] <- NA
  }

  return(FLQuant(res, dimnames= c(list(quant='all'),dimnames(x)[2:6]),
    quant=quant(x), units=units(x)))
})

#' @rdname dimSummaries
#' @aliases yearSums,FLQuant-method
setMethod('yearSums', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x,c(1,3,4,5,6), function(x, NA.RM=na.rm){
    z <- x[!is.na(x)]; ifelse(length(z), sum(z, na.rm=NA.RM), NA)
  }))
})

#' @rdname dimSummaries
#' @aliases unitSums,FLQuant-method
setMethod('unitSums', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x,c(1,2,4,5,6), function(x, NA.RM=na.rm){
    z <- x[!is.na(x)]; ifelse(length(z), sum(z, na.rm=NA.RM), NA)
  }))
})

#' @rdname dimSummaries
#' @aliases seasonSums,FLQuant-method
setMethod('seasonSums', signature(x='FLQuant'), function(x, na.rm=TRUE) {
 
  # output, 1 season
  res <- x[,,,1]
  dimnames(res)$season <- "all"
  
  # DROP dimnames
  dimnames(x) <- NULL
  # PERMUTATE to season first
  x <- aperm(x, c(4,1,2,3,5,6))

  # SUM across dim 1
  res[] <- colSums(x, dims=1, na.rm=TRUE)

  idx <- colSums(is.na(x), dims=1) == dim(x)[1]
  res[idx] <- NA

  return(res)
})

#' @rdname dimSummaries
#' @aliases areaSums,FLQuant-method
setMethod('areaSums', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x,c(1,2,3,4,6), function(x, NA.RM=na.rm){
    z <- x[!is.na(x)]; ifelse(length(z), sum(z, na.rm=NA.RM), NA)
  }))
})

#' @rdname dimSummaries
#' @aliases iterSums,FLQuant-method
setMethod('iterSums', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x,1:5, function(x, NA.RM=na.rm){
    z <- x[!is.na(x)]; ifelse(length(z), sum(z, na.rm=NA.RM), NA)
  }))
})

# }}}

# means         {{{
setMethod('quantMeans', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  res <- colMeans(x, na.rm=na.rm)
  dim(res) <- c(1, dim(res))
  return(FLQuant(res, dimnames= c(list(quant='all'),dimnames(x)[2:6]), quant=quant(x),
    units=units(x)))
})

setMethod('yearMeans', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1,3:6), mean, na.rm=na.rm))
})

setMethod('unitMeans', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1:2,4:6), mean, na.rm=na.rm))
})

setMethod('seasonMeans', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1:3,5,6), mean, na.rm=na.rm))
})

setMethod('areaMeans', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1:4,6), mean, na.rm=na.rm))
})

setMethod('iterMeans', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1:5), mean, na.rm=na.rm))
}) # }}}

# medians {{{
setMethod('iterMedians', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1:5), median, na.rm=na.rm))
}) # }}}

# vars         {{{
setMethod('quantVars', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, 2:6, var, na.rm=na.rm))
})

setMethod('yearVars', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1,3:6), var, na.rm=na.rm))
})

setMethod('unitVars', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1:2,4:6), var, na.rm=na.rm))
})

setMethod('seasonVars', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1:3,5:6), var, na.rm=na.rm))
})

setMethod('areaVars', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1:4,6), var, na.rm=na.rm))
})

setMethod('iterVars', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(apply(x, c(1:5), var, na.rm=na.rm))
}) # }}}

# CVs {{{
setMethod('iterCVs', signature(x='FLQuant'), function(x, na.rm=TRUE) {
  return(sqrt(iterVars(x))/iterMeans(x))
}) # }}}

# quantile   {{{
setMethod("quantile", signature(x="FLQuant"),
  function(x, probs=seq(0, 1, 0.25), na.rm=FALSE, ...) {
    res <- FLQuant(NA, dimnames=c(dimnames(x)[-6],
      list(iter=paste(probs*100, "%", sep=""))), units=units(x))
  res[,,,,,] <- aperm(apply(x@.Data, 1:5, quantile, c(0, probs), na.rm=na.rm),
    c(2:6,1))[,,,,,-1,drop=FALSE]
  return(res)
  }
) # }}}

# iters     {{{
setGeneric("iters", function(object, ...) {
value  <-  standardGeneric("iters")
value
}
)

setMethod("iters", signature(object="FLQuant"),
function(object) {
for (i in dimnames(object)$iter) {
cat("-- iter: ", i,"\n")
print(object@.Data[,,,,,i])
}
cat("\nunits: ", object@units, "\n")
}
)   # }}}

# iter<-     {{{
setGeneric("iter<-", function(object, ..., value)
standardGeneric("iter<-"))
setMethod("iter<-", signature(object="FLQuant", value="FLQuant"),
function(object, iter, value)
{
object[,,,,,iter] <- value
return(object)
}
)   # }}}

# propagate {{{
setMethod("propagate", signature(object="FLQuant"),
  function(object, iter, fill.iter=TRUE)
  {
    dob <- dim(object)

    if(iter == dob[6])
      return(object)

    # CHECK no iters in object
    if(dob[6] > 1)
      stop("propagate can only extend objects with no iters")

    # fill.iter
    if(fill.iter) {
      return(new('FLQuant', array(rep(c(object), iter), dim=c(dob[-6], iter),
        dimnames=c(dimnames(object)[-6], list(iter=seq(iter)))),
        units=units(object)))
    # or NAs
    } else {
      return(new('FLQuant', array(c(object, rep(NA, prod(dob)*(iter-1))),
        dim=c(dim(object)[-6], iter), dimnames=c(dimnames(object)[-6], list(iter=seq(iter)))), units=units(object)))
    }
  }
) # }}}

# rnorm{{{
setMethod("rnorm", signature(n="numeric", mean="FLQuant", sd="FLQuant"),
  function(n=1, mean, sd) {
    if(dim(mean)[6] > 1 | dim(sd)[6] > 1)
      stop("mean or sd can only have iter=1")
    if(any(dim(mean) != dim(sd)))
      stop("dims of mean and sd must be equal")
    FLQuant(array(rnorm(prod(dim(mean)[-6])*n, rep(iter(mean, 1)[drop=TRUE], n),
      rep(iter(sd, 1)[drop=TRUE], n)), dim=c(dim(mean)[-6], n)),
      dimnames=c(dimnames(mean)[-6], list(iter=seq(n))), units=units(mean))
  }
)

setMethod("rnorm", signature(n="numeric", mean="FLQuant", sd="numeric"),
  function(n=1, mean, sd) {
    rnorm(n, mean, FLQuant(sd, dimnames=dimnames(mean)))
  }
)
setMethod("rnorm", signature(n="numeric", mean="numeric", sd="FLQuant"),
  function(n=1, mean, sd) {
    rnorm(n, FLQuant(mean, dimnames=dimnames(sd)), sd)
  }
)
setMethod("rnorm", signature(n="numeric", mean="FLQuant", sd="missing"),
  function(n=1, mean) {
    rnorm(n, mean, 1)
  }
)
setMethod("rnorm", signature(n="numeric", mean="missing", sd="FLQuant"),
  function(n=1, sd) {
    rnorm(n, 0, sd)
  }
)
setMethod("rnorm", signature(n="missing", mean="FLQuant", sd="numeric"),
  function(mean, sd=1) {
    mean[] <- rnorm(length(mean), c(mean), sd)
    return(mean)
  }
)
setMethod("rnorm", signature(n="missing", mean="numeric", sd="FLQuant"),
  function(mean=0, sd) {
    sd[] <- rnorm(length(sd), mean, c(sd))
    return(sd)
  }
)
setMethod("rnorm", signature(n="missing", mean="FLQuant", sd="FLQuant"),
  function(mean, sd) {
    if(!all(dim(mean) == dim(sd)))
      stop("dimensions of 'mean' and 'sd' must be the same")
    mean[] <- rnorm(length(mean), c(mean), c(sd))
    return(mean)
  }
)
# }}}

# rlnorm {{{
setMethod("rlnorm", signature(n='numeric', meanlog="FLQuant", sdlog="FLQuant"),
  function(n=1, meanlog, sdlog) {
    if(dim(meanlog)[6] > 1 | dim(sdlog)[6] > 1)
      stop("meanlog or sdlog can only have iter=1")
    if(all(dim(meanlog) != dim(sdlog)))
      stop("dims of meanlog and sdlog must be equal")
    FLQuant(array(rlnorm(prod(dim(meanlog)[-6])*n,
      rep(iter(meanlog, 1)[drop=TRUE], n),
      rep(iter(sdlog, 1)[drop=TRUE],n)), dim=c(dim(meanlog)[-6], n)),
      dimnames=c(dimnames(meanlog)[-6], list(iter=seq(n))), fill.iter=TRUE,
      units=units(meanlog))
  }
)

setMethod("rlnorm", signature(n='numeric', meanlog="FLQuant", sdlog="numeric"),
  function(n=1, meanlog, sdlog) {
    rlnorm(n, meanlog, FLQuant(sdlog, dimnames=dimnames(meanlog)))
  }
)

setMethod("rlnorm", signature(n='numeric', meanlog="numeric", sdlog="FLQuant"),
  function(n=1, meanlog, sdlog)
    rlnorm(n, FLQuant(meanlog, dimnames=dimnames(sdlog)), sdlog)
)

setMethod("rlnorm", signature(n='numeric', meanlog="FLQuant", sdlog="missing"),
  function(n=1, meanlog, sdlog)
    rlnorm(n, meanlog, 1)
)

setMethod("rlnorm", signature(n='numeric', meanlog="missing", sdlog="FLQuant"),
  function(n=1, meanlog, sdlog)
    rlnorm(n, 0, sdlog)
)

setMethod("rlnorm", signature(n='FLQuant', meanlog="ANY", sdlog="ANY"),
  function(n, meanlog=0, sdlog=1) {
    FLQuant(rlnorm(length(n), meanlog, sdlog), dimnames=dimnames(n), units=units(n))
  }
)
setMethod("rlnorm", signature(n="missing", meanlog="FLQuant", sdlog="ANY"),
  function(meanlog, sdlog=1) {
    meanlog[] <- rlnorm(length(meanlog), c(meanlog), sdlog)
    return(meanlog)
  }
)
setMethod("rlnorm", signature(n="missing", meanlog="FLQuant", sdlog="FLQuant"),
  function(meanlog, sdlog) {
    if(!all(dim(meanlog) == dim(sdlog)))
      stop("dimensions of 'meanlog' and 'sdlog' must be the same")
    meanlog[] <- rlnorm(length(meanlog), c(meanlog), c(sdlog))
    return(meanlog)
  }
)
# }}}

# rpois{{{
setMethod("rpois", signature(n='numeric', lambda="FLQuant"),
function(n=1, lambda) {
    if(dim(lambda)[6] > 1)
      stop("lambda can only have iter=1")
FLQuant(array(rnorm(prod(dim(lambda)[-6])*n, rep(iter(lambda, 1)[drop=TRUE], n)),
      dim=c(dim(lambda)[-6], n)),
dimnames=c(dimnames(lambda)[-6], list(iter=seq(n))), fill.iter=TRUE, units=units(lambda))
}
) # }}}

# mvrnorm {{{
setMethod("mvrnorm",
  signature(n="numeric", mu="FLQuant", Sigma="matrix"),
  function(n=1, mu, Sigma) {

    dmu <- dim(mu)

    # input checks
    if(any(dmu[3:6] > 1))
      stop("mvrnorm can only work on 'quant' by 'year' FLQuant objects")
    if (!isSymmetric(Sigma, tol = sqrt(.Machine$double.eps),
      check.attributes = FALSE)) {
      stop("Sigma must be a symmetric matrix")
    }
    if (dmu[1] != nrow(sigma)) {
      stop("mu and Sigma have non-conforming size")
    }

    # "chol" method, from mvtnorm pkg
    retval <- chol(Sigma, pivot = TRUE)
    o <- order(attr(retval, "pivot"))
    retval <- retval[, o]

    retval <- matrix(rnorm(n * prod(dmu)), nrow = n * dmu[2]) %*% retval

    # iter, year, age, unit, season, area
    dim(retval)<-c(n, dmu[2], dmu[1], 1, 1, 1)

    # aperm into FLQ
    retval <- mu + FLQuant(aperm(retval, c(3,2,4,5,6,1)))

    return(retval)
  }
)

setMethod("mvrnorm",
  signature(n="numeric", mu="FLQuant", Sigma="missing"),
  function(n=1, mu) {

    #
    Sigma <- cov(t(mu[, drop=TRUE]))

    return(mvrnorm(n, mu, Sigma))

  }
)# }}}

# PV{{{
setGeneric("pv", function(object, ...)
standardGeneric("pv"))

# Heath. 2006. Oikos 115:573-581
setMethod('pv', signature(object='FLQuant'),
function(object, dist=FALSE)
{
# dimensions (currently working for (1,n,1,1,1,1)
if(any(dim(object)[c(1,3:6)] != rep(1,5)))
stop('the pv method is currently defined for yearly time series only, dim = c(1,n,1,1,1,1)')

# delete NAs
object <- as.vector(object)
object <- object[!is.na(object)]

# number of possible combinations (Eq. 1)
len <- length(object)
c <- len*(len-1)/2

# all possible combinations
grid <- as.data.frame(t(combn(as.vector(object), 2)))

# absolut value (Eq. 2)
grid$Abs <- abs(grid$V1-grid$V2)

# max and min by row (Eq. 2)
grid$Max <- apply(cbind(grid$V1, grid$V2), 1, max)
grid$Min <- apply(cbind(grid$V1, grid$V2), 1, min)

# calculate PV and D(PV)
pv <- grid$Abs/grid$Max
pv[grid$Abs == 0]  <- 0
pv <- sum(pv) / c
pvd <- 1- (grid$Min/grid$Max)
pvd[grid$Abs == 0]  <- 0

if(dist == TRUE)
return(pvd)
return(pv)
}
)
# }}}

# setPlusGroup{{{
setGeneric("setPlusGroup", function(x, plusgroup, ...)
standardGeneric("setPlusGroup"))
setMethod("setPlusGroup", signature(x='FLQuant', plusgroup='numeric'),
function(x, plusgroup, na.rm=FALSE, by='mean') {
# only valid for age-based FLQuant
if(quant(x) != 'age')
stop('setPlusGroup onoy makes sense for age-based FLQuant objects')
# plusgroup not < than minage
  if ((plusgroup) < dims(x)$min)
  stop("plusgroup < min age")

  # expand
  if ((plusgroup) > dims(x)$max) {
    dmns <-dimnames(x)
    dmns$age <-dims(x)$min:plusgroup
    oldMaxage<-dims(x)$max

    # create extra ages and fill with plusgroup
    res  <-FLQuant(x, dimnames=dmns)
    res[ac((oldMaxage+1):plusgroup)] <- 0;
    res[ac((oldMaxage+1):plusgroup)] <- sweep(res[ac((oldMaxage+1):plusgroup)],
      2:6, res[ac(oldMaxage)],"+")

    if (by != "mean")
      res[ac((oldMaxage + 1):plusgroup)] <- res[ac((oldMaxage + 1):plusgroup)]/
        (plusgroup-oldMaxage + 1)

  }
  # trim
  else {
    res <- trim(x, age=dims(x)$min:plusgroup)
    res[as.character(plusgroup)] <- switch(by,
      'mean'= quantMeans(x[as.character(plusgroup:dims(x)$max)], na.rm=na.rm),
      'sum'= quantSums(x[as.character(plusgroup:dims(x)$max)], na.rm=na.rm))
  }

return(res)
}
)# }}}

# sweep {{{
if (!isGeneric("sweep"))
setGeneric("sweep", function (x, MARGIN, STATS, FUN = "-", check.margin = TRUE, ...)
standardGeneric("sweep"))

setMethod('sweep', signature(x='FLQuant'),
  function(x, MARGIN, STATS, FUN, check.margin=TRUE, ...)
  {
    res <- callNextMethod()
    FLQuant(res, units=units(x))
  }
) # }}}

# as.data.frame(FLQuant) {{{
setMethod("as.data.frame", signature(x="FLQuant", row.names="missing",
  optional="missing"),
    function(x, cohort=FALSE, timestep=FALSE, date=FALSE, drop=FALSE) {
        as.data.frame(x, row.names=NULL, cohort=cohort, timestep=timestep,
            date=date, drop=drop)
    }
)
setMethod("as.data.frame", signature(x="FLQuant", row.names="ANY",
  optional="missing"),
function(x, row.names, cohort=FALSE, timestep=FALSE, date=FALSE, drop=FALSE) {

    res <- callNextMethod(x)

    # create cohort column as year - age
    if(cohort) {
      res$cohort  <-  "all"
      if(quant(x) == "age")
        if(!any(is.na(dims(x)[c('min', 'max')])))
          res$cohort <- res$year - res$age
    }

    # create timestep column
    if(timestep) {
        res$timestep <- (as.numeric(res$year) - min(res$year)) * dim(x)[4] +
            as.numeric(res$season)
    }

    # create date column
    if(date) {
    lens <- (ISOdate(2014, 12, 31) - ISOdate(2014, 1, 1)) / dim(x)[4]
    res$date <- ISOdate(res$year, 1, 1) + lens * (as.numeric(res$season) - 1)
    }

    # drops columns with a single value, i.e. dims of length=1
    if(drop) {
      idx <- names(x)[dim(x) == 1]
      res <- res[, !colnames(res) %in% idx]
    }

    return(res)
  }
) # }}}

# combine {{{
setMethod('combine', signature(x='FLQuant', y='FLQuant'),
  function(x, y) {

    dx <- dim(x)
    dy <- dim(y)

    # dim(x)[1:5] == dim(x)[1:5]
    if(any(dx[-6] != dy[-6]))
      stop("Object dimensions [1:5] must match")

    #
    if(!all.equal(dimnames(x)[1:5], dimnames(y)[1:5]))
      warning("dimnames of x and y differ")

    itx <- dx[6]
    ity <- dy[6]

    res <- FLQuant(NA, dimnames=c(dimnames(x)[1:5], list(iter=seq(itx + ity))),
      units=units(x))
    res[,,,,,1:itx] <- x
    res[,,,,,(itx+1):(itx+ity)] <- y
    return(res)
  }
) # }}}

# ifelse {{{
setMethod("ifelse", signature(test="FLQuant", yes="ANY", no="ANY"),
  function(test, yes, no) {
    
    uts <- units(test)
    dmns <- dimnames(test)

    test <- as(test, 'logical')
    yes <- c(yes)
    no <- c(no)

    res <- callNextMethod()

    return(FLQuant(res, dimnames=dmns, units=uts))
  }
) 

setMethod("ifelse", signature(test="ANY", yes="ANY", no="FLQuant"),
  function(test, yes, no) {
    
    uts <- units(no)
    dmns <- dimnames(no)

    test <- as(test, 'logical')
    yes <- c(yes)
    no <- c(no)

    res <- callNextMethod()

    return(FLQuant(res, dimnames=dmns, units=uts))
  }
)

setMethod("ifelse", signature(test="ANY", yes="FLQuant", no="ANY"),
  function(test, yes, no) {
    
    uts <- units(yes)
    dmns <- dimnames(yes)

    test <- as(test, 'logical')
    yes <- c(yes)
    no <- c(no)

    res <- callNextMethod()

    return(FLQuant(res, dimnames=dmns, units=uts))
  }
)
# }}}

# tail {{{
setMethod("tail", signature(x="FLQuant"),
  function(x, n=1, dim=2, ...) {

    # dim of length 1
    if(length(dim) > 1)
      stop("tail(FLQuant) can only apply to a single dim(ension)")

    # character dim
    if(is(dim, 'character'))
      dim <- which(dim == names(x))

    # named list of dimension vectors
    idx <- lapply(as.list(dim(x)), seq)
    names(idx) <- c('i','j','k','l','m','n')

    # tail dimension set by dim
    idx[[dim]] <- tail(idx[[dim]], n=n)

    # apply '['
    return(do.call('[', c(list(x=x), idx)))
  }
) # }}}

# tS, tS<- {{{
setMethod("tS", signature(object="FLQuant", step="numeric"),
  function(object, step) {

  # dims
  do <- dim(object)[c(2,4)]

  # find pout season and year
  season <- step %% do[2]
  year <- step %/% do[2] + 1

  # correct for those in season 4
  idx <- (step %% do[2]) == 0
  year[idx] <- (step %/% do[2]) [idx]
  season[idx] <- do[2]

  # Are n elements contiguous in years or seasons ?
  if(length(unique(year)) > 1 & length(unique(season)) > 1)
    stop("requested time steps do not generate a consistent object")

  return(object[, unique(year), ,unique(season),,])
  }
)

setMethod("tS<-", signature(object="FLQuant", step="numeric", value="vector"),
  function(object, step, value) {

  # dims
  do <- dim(object)[c(2,4)]

  # find pout season and year
  season <- step %% do[2]
  year <- step %/% do[2] + 1

  # correct for those in season 4
  idx <- (step %% do[2]) == 0
  year[idx] <- step %/% do[2]
  season[idx] <- do[2]

  object[, unique(year), ,unique(season),,]  <- value

  return(object)
  }
)

# }}}

# tsp {{{
setMethod("tsp", signature(x="FLQuant"),
  function(x) {
    dms <- dimnames(x)
    return(c(as.numeric(dms$year[c(1, length(dms$year))]), length(dms$season)))
  }
) # }}}

# $ {{{
#' @rdname Extract
#' @aliases $,FLQuant-method
setMethod("$", signature(x="FLQuant"),           
  function(x, name) {
    return(x[name,])
  }
) # }}}

# NOT EXPORTED
# filldimnames       {{{
filldimnames <- function(dnames, dim=rep(1,6), iter=1) {
# check only one name for quant in input
if(length(names(dnames)[!names(dnames)%in%c("year","unit","season","area","iter")]) > 1)
stop("more than one vector of names given for the first dimension")
# generate standard names for given dimensions
xnames <- dimnames(FLQuant(dim=dim, iter=iter))
for(i in 1:length(dnames)) {
# non-quant names
if(any(names(dnames)[i]==c("year","unit","season","area","iter")))
xnames[[names(dnames)[i]]] <- dnames[[i]]
# quant
else {
xnames[[1]] <- dnames[[i]]
names(xnames)[1] <- names(dnames)[i]
}
}
return(xnames)
} # }}}
