highlight clear SignColumn
highlight clear LineNr

function! JumpFuncName()
  call search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW')
endfunction

function! ShowFuncName()
  let lnum = line(".")
  let col = col(".")
  echohl ModeMsg
  echo getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))
  echohl None
  call search("\\%" . lnum . "l" . "\\%" . col . "c")
endfunction

" fzf.vim
function! s:gtags_sink(lines)
  if len(a:lines) < 2
    return
  endif
  execute 'tag ' . split(a:lines[1], '')[0]
endfunction

function! fzf#vim#gtags(query, ...)
  let opts = []

  return s:fzf('gtags', {
  \ 'source':  'global -x .',
  \ 'sink*':   s:function('s:gtags_sink'),
  \ 'options': extend(opts, ['--nth', '1..2', '-m', '--tiebreak=begin', '--prompt', 'Gtags> ', '--query', a:query])}, a:000)
endfunction

function! s:ag_to_qf(line, has_column)
  let parts = split(a:line, '[^:]\zs:\ze[^:]')
  let text = join(parts[(a:has_column ? 3 : 2):], ':')
  if filereadable(parts[0])
    let dict = {'filename': &acd ? fnamemodify(parts[0], ':p') : parts[0], 'lnum': parts[1], 'text': text}
    if a:has_column
      let dict.col = parts[2]
    endif
  else
    let dict = {'filename': &acd ? fnamemodify(expand('%'), ':p') : expand('%'), 'lnum': parts[0], 'text': text}
    if a:has_column
      let dict.col = parts[1]
    endif
  endif
  return dict
endfunction

function! fzf#vim#grep(grep_command, has_column, ...)
  let cmd = a:grep_command
  echomsg cmd
  if match(a:grep_command, matchstr(a:grep_command, '\S\+\s%\S'))
	  let cmd =  substitute(a:grep_command, '\s%', '', '') . ' ' .  expand('%')
  endif

  let $FZF_DEFAULT_COMMAND = cmd
