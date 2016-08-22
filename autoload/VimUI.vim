" The user will be given a list of options, each one numbered. They can enter
" the number of one of the options, or press ESC to cancel.
" If you set start_at to 1, then options will be numbered starting with '1',
" instead of '0'
" If the user aborts, or there are no options, then -1 is returned.
" Otherwise, the index of one of the options will be returned.
function! VimUI#SelectOne(prompt, options, start_at)
  if ! len(a:options)
    return -1
  endif

  " we want to have minimum 3 spaces between each column
  let l:min_space = 3

  " put two spaces to the left of each line
  let l:row_pad = repeat(' ', 2)

  " always have a minimum of 2 columns
  let l:min_columns = 1

  " never have more than 20 columns
  let l:max_columns = 20

  " use 8 lines less than the full terminal size
  let l:height_buffer = 8

  redraw!
  echohl WarningMsg
  echo a:prompt
  echohl None

  " work out the maximum number of items we can fit in one line (8 less than
  " window height as a buffer to allow for a very long prompt)
  let l:max_per_column = &g:lines - l:height_buffer

  " work out how many columns are needed, respecting the minimum/maximum cols
  let l:num_columns = len(a:options) / l:max_per_column
  if len(a:options) % l:max_per_column
    let l:num_columns += 1
  endif
  if l:num_columns < l:min_columns
    let l:num_columns = l:min_columns
  elseif l:num_columns > l:max_columns
    let l:num_columns = l:max_columns
  endif

  " how many items will need to be shown in the tallest column?
  let l:tallest = len(a:options) / l:num_columns
  if len(a:options) % l:num_columns
    let l:tallest += 1
  endif

  " split the options into separate lists, one per column
  let l:options_by_column = repeat([[]], l:num_columns)
  for l:col in range(l:num_columns)
    let l:start_idx = l:col * l:tallest
    let l:end_idx = (l:start_idx + l:tallest) - 1
    let l:segment = a:options[(l:start_idx):(l:end_idx)]
    let l:options_by_column[l:col] = l:segment
  endfor

  " what is the max width needed for each column? (Don't calculate it right
  " now)
  let l:longest_item = repeat([0], l:num_columns)

  " what is the highest number in each column?
  let l:highest_idx = repeat([0], l:num_columns)

  " ensure this value is a number
  let l:start_at = a:start_at * 1
  
  " start rendering the columns, one row at a time
  for l:row in range(l:tallest)
    " start a new line for output
    echo l:row_pad

    " render each column
    for l:col in range(l:num_columns)
      if l:row == 0
        " work out what width is needed for this column
        let l:longest_item[l:col] = max(map(copy(l:options_by_column[l:col]), "strlen(v:val)"))

        " work out what is the highest number in this column
        let l:highest_idx[l:col] = (l:col * l:tallest) + (l:tallest - 1) + l:start_at
      endif

      if l:col > 0
        " we need to print the 3 spaces padding before this item
        echon repeat(' ', l:min_space)
      endif

      " print the number of the item first
      let l:number = l:row + (l:col * l:tallest) + l:start_at

      let l:item = get(l:options_by_column[l:col], l:row, "")
      if l:item == ''
        let l:number = ''
      endif

      let l:prefix = repeat(' ', strlen(l:highest_idx[l:col]) - strlen(l:number)).l:number.' '
      echohl Macro
      echon l:prefix
      echohl None
      echon l:item.repeat(' ', l:longest_item[l:col] - strlen(l:item))
    endfor
  endfor

  echohl Question
  let l:choice = input('Number: ')
  echohl None

  if l:choice == ""
    return -1
  endif

  if l:choice =~ '^\d\+$'
    let l:adjusted = l:choice - l:start_at
    if l:adjusted >= 0 && l:adjusted < len(a:options)
      return l:adjusted
    endif
  endif

  echohl Error
  echo 'Invalid input:' l:choice
  echohl None
  return -1
endfunction

