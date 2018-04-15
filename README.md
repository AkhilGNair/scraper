library(dplyr)
library(tidyr)
library(ggplot2)

URL = 'https://global.americanexpress.com/myca/intl/istatement/emea/v1/statement.do?Face=en_GB&method=displayStatement&sorted_index=0&BPIndex=0#/'

options = list(chromeOptions = list(
  args = c('--headless', '--disable-gpu', '--window-size=1280,800')
))

driver = RSelenium::rsDriver(browser = "chrome", verbose = FALSE, extraCapabilities = options)

client = driver$client
client$navigate(URL)

scrapers::login(client, Sys.getenv('AMEXUSERNAME'), Sys.getenv('AMEXPASSWORD'))
scrapers::select_all(client, "2016-11-16")
scrapers::load_all(client)

scrappers::get_transaction_table(client) %>%
  tibble::as_tibble() %>% 
  separate(Amount, into = c("junk", "amount"), sep = " ") %>%
  mutate(amount = stringr::str_replace_all(amount, "[£ ,]", "") %>% as.numeric()) %>%
  mutate(Date = Date %>% as.Date(format = "%d %b %y")) -> tbl

tbl_credit = tbl %>% filter(amount > 0)
tbl_debit = tbl %>% filter(amount < 0)

ggplot(tbl_credit %>% arrange(Date) %>% mutate(cumulative = cumsum(amount))) +
  geom_bar(
    aes(x = Date, y = cumulative, group = Description),
    position = "identity", stat = "identity", fill = "steelblue",
  ) +
  theme_minimal() +
  labs(
    title = "Total spend on Amex card",
    x = "Date", 
    y = "Cumulative Spend"
  ) +
  scale_y_continuous(labels = scales::dollar_format(prefix = "£"))
