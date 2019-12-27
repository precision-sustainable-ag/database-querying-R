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
