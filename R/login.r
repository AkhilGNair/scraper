#' Handle the login page
#'  - Close the cookies banner
#'  - Enter username and password
#'  - Wait for the transactions page to load
#'
#' @param client 
#' @param username 
#' @param password 
#'
#' @export
login = function(client, username, password) {
  
  login_page = login_factory(client)
  
  login_page$close_banner()
  login_page$enter_details(username, password)
  login_page$wait()
  
}

SEL_USERNAME       = 'lilo_userName'
SEL_PASSWORD       = 'lilo_password'
SEL_COOKIES        = 'sprite-close_btn'
SEL_MAIN_LOADER    = 'MainLoader'
SEL_LOGIN_ERROR    = 'lilo_loginErrMsg'
STYLE_DISPLAY_NONE = 'display: none;'
KEY_ENTER          = 'enter'

login_factory = function(client) {
  
  enter_details = function(username, password) {
    elem_username = client$findElement(SEL_USERNAME, using = "id")
    elem_password = client$findElement(SEL_PASSWORD, using = "id")
    
    # key = ENTER sends the enter key after inputting the text
    elem_username$sendKeysToElement(list(username))
    elem_password$sendKeysToElement(list(password, key = KEY_ENTER))
    
    if (login_error()) stop("Username/Password combination incorrect")
  }
  
  wait = function() {
    page_status = get_mainLoader_style()
    while (page_status != STYLE_DISPLAY_NONE) {
      page_status = get_mainLoader_style()
    }
    # Extra wait after the page has loaded to ensure the 
    # datepicker widget loads
    Sys.sleep(3)
  }
  
  close_banner = function() {
    banner = client$findElement(SEL_COOKIES, using = 'id')$clickElement()
  }
  
  get_mainLoader_style = function() {
    client$findElement(SEL_MAIN_LOADER, using = 'id')$getElementAttribute('style')
  }
  
  login_error = function() {
    length(client$findElements(SEL_LOGIN_ERROR, using = 'id')) > 0
  }
  
  list(
    close_banner  = close_banner,
    enter_details = enter_details,
    wait          = wait
  )
  
}
