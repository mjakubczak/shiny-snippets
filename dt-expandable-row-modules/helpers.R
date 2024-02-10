# avoid cache
with_hash <- function(file_path, www_path){
  hash <- tools::md5sum(file_path)
  paste(www_path, hash, sep = "?")
}

generate_module_id <- function(rowId){
  paste0("x", rowId)
}

format_dt <- function(df){
  module_ids <- sapply(
    X = seq_len(nrow(df)),
    FUN = generate_module_id # generate module ID for every row
  )
  
  output_containers <- sapply(
    X = module_ids,
    FUN = function(id){
      # get UI for every module and store it in a hidden column
      as.character(my_moduleUI(id))
    }
  )
  
  cbind(
    data.frame(Expand = ""), # expand buttons
    df, # the data
    data.frame( # hidden columns (see DT options)
      module_id = module_ids,
      output_container = output_containers
    )
  )
}
