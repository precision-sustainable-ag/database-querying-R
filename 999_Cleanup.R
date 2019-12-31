# Anonymize HTML output

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

# Find `library` calls
fs::dir_ls(glob = "*.Rmd") %>% 
  purrr::map(~{
    rtext <- readr::read_lines(.x)
    
    libs <- stringr::str_extract_all(rtext, "library\\(.+\\)")
    purrr::compact(libs) %>% unlist()
  })

# Find namespace calls
fs::dir_ls(glob = "*.Rmd") %>% 
  purrr::map(~{
    rtext <- readr::read_lines(.x)
    
    colons <- stringr::str_extract_all(rtext, "\\b[A-z0-9]+::[.A-z0-9_]+")
    purrr::compact(colons) %>% unlist() %>% sort() %>% unique()
  })
