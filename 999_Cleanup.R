## Anonymize HTML output

fs::dir_ls(glob = "*.html") %>%
  purrr::walk(~{
    html_text <- readr::read_lines(.x) 
    
    flags <- stringr::str_detect(html_text, "^#.+/crowndb\\]$")
    
    if (any(flags)) {
      idx <- glue::glue_collapse(which(flags), sep = ", ")
      message("File: ", .x, "\n  removing lines: ", idx)
    }
    
    html_text[!flags] %>% 
      readr::write_lines(.x)
  })

## Find `library` calls
fs::dir_ls(glob = "*.Rmd") %>% 
  purrr::map(~{
    rtext <- readr::read_lines(.x)
    
    libs <- stringr::str_extract_all(rtext, "library\\(.+\\)")
    purrr::compact(libs) %>% unlist()
  })

## Find namespace calls
fs::dir_ls(glob = "*.Rmd") %>% 
  purrr::map(~{
    rtext <- readr::read_lines(.x)
    
    colons <- stringr::str_extract_all(rtext, "\\b[A-z0-9]+::[.A-z0-9_]+")
    purrr::compact(colons) %>% unlist() %>% sort() %>% unique()
  })

## Setup chunk
options(crayon.enabled = FALSE)


## Hide DB src in interactive use
library(dbplyr)
tbl(con, "cc_species")

# source from dbplyr:::db_desc.PqConnection
new_db_desc <- function (x) {
  info <- dbGetInfo(x)
  host <- if (info$host == "") 
      "localhost"
    else info$host
  paste0("postgres ", info$serverVersion, " [...]")
}

assignInNamespace(
  "db_desc.PqConnection", 
  new_db_desc,
  "dbplyr",
  envir = asNamespace("dbplyr")
  )

# now hidden
tbl(con, "cc_species")

# reload
detach("package:dbplyr", unload = TRUE)
library(dbplyr)

# now reverted
tbl(con, "cc_species")
