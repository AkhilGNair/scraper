SEL_LOAD_MORE = '#transLoadMore > button'
SEL_LOAD_MORE_WRAPPER = 'transLoadMore'

#' Load all
#' 
#' Loads the entire transaction history for the selected period
#'
#' @param client 
#' @export
load_all = function(client) {
  
  click_button = function()
    client$findElement(SEL_LOAD_MORE, using = 'css selector')$clickElement()
  
  hidden = function() {
    wrapper = client$findElement(SEL_LOAD_MORE_WRAPPER, using = 'id')
    hidden = wrapper$getElementAttribute('aria-hidden')
    if (hidden == 'true') return(TRUE)
    FALSE
  }
  
  Sys.sleep(3)
  
  while (!hidden()) click_button()
}

#' Get Transaction Table
#' 
#' Downloads a table of transactions by css id
#' @export
get_transaction_table = function(client) {
  # Read in the page source
  html = xml2::read_html(client$getPageSource()[[1]])
  # Find the transaction table
  html_table = rvest::html_nodes(html, "#transaction-table")
  # Extract the table element
  rvest::html_table(html_table)[[1]]
}
