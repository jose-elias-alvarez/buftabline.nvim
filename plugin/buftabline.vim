if exists ("g:loaded_buftabline")
	finish
endif

let g:loaded_buftabline = 1

command! ToggleBuftabline lua require("buftabline").toggle_tabline()
