#' Select all dates from an initial date to today's date
#'  - Open the date widget
#'  - Navigate to the start month
#'  - Click the start day
#'  - Navigate to the current month
#'  - Click today's day
#'  - Submit the form
#'
#' @param client 
#' @param start_date 
#'
#' @export
select_all = function(client, start_date) {
  
  # Check start date can be interpreted as a date
  start_date = as.Date(start_date, format = "%Y-%m-%d")
  if (is.na(start_date) | (class(start_date) != "Date")) 
    stop("Please pass 'start_date' as a Date (using 'as.Date()')")
  
  datepicker = datepicker_factory(client)
  
  target_month_year = strftime(start_date, format = '%B %Y')
  target_day = strftime(start_date, format = '%d')
  
  # Manipulate the date widget
  datepicker$open()
  datepicker$select_month(target_month_year)
  datepicker$click_date(target_day)
  datepicker$select_month()
  datepicker$click_date()
  datepicker$submit()

}

# Selectors
SEL_DATE_WIDGET = '#daterange > div > p.menu-subheader.ng-binding.ng-scope'
SEL_DATE_WIDGET_MORE_DATES = '#dateRangeContainer > div.filterMenu > ul > li:nth-child(8)'
SEL_DATE_WIDGET_CURRENT_MONTH = '#calendarFn'
SEL_DATE_WIDGET_LEFT_CHEVRON = '#calendar > table > thead > tr:nth-child(1) > th:nth-child(1) > button > i'
SEL_DATE_WIDGET_RIGHT_CHEVRON = '#calendar > table > thead > tr:nth-child(1) > th:nth-child(3) > button > i'
SEL_DATE_WIDGET_CELL = '#calendar > table > tbody > tr > td > button > span'
SEL_SUBMIT = '#customDate > button'

datepicker_factory = function(client) {

  #  Opens the datepicker widget
  open = function() {
    client$findElement(SEL_DATE_WIDGET, using = 'css selector')$clickElement()
    client$findElement(SEL_DATE_WIDGET_MORE_DATES, using = 'css selector')$clickElement()
  }
  
  # Submits the widget with selected dates
  submit = function() 
    client$findElement(SEL_SUBMIT, using = 'css selector')$clickElement()
  
  # Moves the selected month back one
  move_back_month = function() 
    client$findElement(SEL_DATE_WIDGET_LEFT_CHEVRON, using = 'css selector')$clickElement()
  
  # Moves the selected month forward one
  move_forward_month = function() 
    client$findElement(SEL_DATE_WIDGET_RIGHT_CHEVRON, using = 'css selector')$clickElement()
  
  # Gets the text of the current month displayed by the widget 
  current_month = function() 
    client$findElement(SEL_DATE_WIDGET_CURRENT_MONTH, using = 'css selector')$getElementText()
  
  # Moves the widget to a target month
  select_month = function(month_year = NA) {
    
    move_month = move_back_month
    
    if (is.na(month_year)) {
      # If no date is given, move forwards to today's date 
      # This can only be 'ahead' in time
      month_year = strftime(lubridate::today(), format = '%B %Y')
      move_month = move_forward_month
    }
    
    while (current_month() != month_year) move_month()
  }
  
  # Helper functions to get the specified date in a month
  # Must first trim off dates from previous month
  get_dates = function(date_elems) 
    vapply(date_elems, function(elem) elem$getElementText(), FUN.VALUE = list(1))
  
  trim = function(date, dates, date_elements) 
    date_elements[which(dates == date)[1]:length(date_elements)]
  
  click_date = function(date = NA) {
    if (is.na(date)) date = strftime(lubridate::today(), format = '%d')
    
    date_elements = client$findElements(SEL_DATE_WIDGET_CELL, using = 'css selector')
    dates = get_dates(date_elements)
    date_elements = trim('01', dates, date_elements)
    
    # Trims the left dates to date, returns the first element 
    dates = get_dates(date_elements)
    date_element = trim(date, dates, date_elements)[[1]]
    
    date_element$clickElement()
  }
  
  # Returns only the functions used and exposed by the factory
  list(
    open         = open,
    select_month = select_month,
    click_date   = click_date,
    submit       = submit
  )
    
}
