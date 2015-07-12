#' Post IDs to Eutils for later use
#'
#'
#'
#'@export
#'@param db character Name of the database from which the IDs were taken
#'@param id vector with unique ID(s) for reacods in database \code{db}. 
#'@param web_history A web_history object. Can be used to add to additional
#' identifiers to an existing web environment on the NCBI 
#'@param \dots character Additional terms to add to the request 
#'@param config vector configuration options passed to httr::GET  
#'@seealso \code{\link[httr]{config}} for available configs 
#'@return QueryKey integer identifier for specific query in webhistory
#'@return WebEnv character identifier for session key to use with history
#'@import XML
#'
#' @examples
#'\dontrun{  
#' so_many_snails <- entrez_search(db="nuccore", 
#'                       "Gastropoda[Organism] AND COI[Gene]", retmax=200)
#' upload <- entrez_post(db="nuccore", id=so_many_snails$ids)
#' cookie <- upload$WebEnv
#' first <- entrez_fetch(db="nuccore", rettype="fasta", WebEnv=cookie,
#'                       query_key=upload$QueryKey, retmax=10)
#' second <- entrez_fetch(db="nuccore", file_format="fasta", WebEnv=cookie,
#'                        query_key=upload$QueryKey, retstart=10, retmax=10)
#'}

entrez_post <- function(db, id=NULL, web_history=NULL, config=NULL, ...){
    args  <-list("epost", db=db, config=config, id=id, web_history=web_history, ...)
    if(!is.null(web_history)){
        args <- c(args, WebEnv=web_history$WebEnv, query_key = web_history$QueryKey)
        args$web_history <- NULL
    }
    response  <- do.call(make_entrez_query, args)
    record <- XML::xmlTreeParse(response, useInternalNodes=TRUE)
    result <- XML::xpathApply(record, "/ePostResult/*", XML::xmlValue)
    names(result) <- c("QueryKey", "WebEnv")
    class(result) <- c("web_history", "list")
    #NCBI limits requests to three per second
    Sys.sleep(0.33)
    return(result)
}


