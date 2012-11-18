" Author:  Eric Van Dewoestine
"
" License: {{{
"
" Copyright (C) 2012  Eric Van Dewoestine
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.
"
" }}}

" Script Variables {{{
let s:command_list_interperters = '-command python_list_interpreters'
let s:command_add_interperter = '-command python_add_interpreter -p "<path>"'
let s:command_remove_interperter = '-command python_remove_interpreter -p "<path>"'
let s:command_list_versions = '-command python_list_versions'
" }}}

function! eclim#python#project#ProjectCreatePre(folder) " {{{
  return s:InitPydev(a:folder)
endfunction " }}}

function! eclim#python#project#ProjectNatureAddPre(project) " {{{
  return s:InitPydev(eclim#project#util#GetProjectRoot(a:project))
endfunction " }}}

function! eclim#python#project#InterpreterList() " {{{
  let workspace = eclim#eclipse#ChooseWorkspace()
  let interpreters = eclim#python#project#GetInterpreters(workspace)
  if !type(interpreters) == g:LIST_TYPE
    return
  endif

  let pad = 0
  for interpreter in interpreters
    let pad = len(interpreter.name) > pad ? len(interpreter.name) : pad
  endfor

  let output = []
  for interpreter in interpreters
    let name = eclim#util#Pad(interpreter.name, pad)
    call add(output, name . ' - ' . interpreter.path)
  endfor

  call eclim#util#Echo(join(output, "\n"))
endfunction " }}}

function! eclim#python#project#InterpreterAdd(path) " {{{
  let workspace = eclim#eclipse#ChooseWorkspace()
  let port = eclim#client#nailgun#GetNgPort(workspace)

  call eclim#util#Echo("Adding interpreter...")
  let command = substitute(s:command_add_interperter, '<path>', a:path, '')
  let result = eclim#ExecuteEclim(command, port)
  if type(result) == g:STRING_TYPE
    call eclim#util#Echo(result)
  endif
endfunction " }}}

function! eclim#python#project#InterpreterRemove(path) " {{{
  let workspace = eclim#eclipse#ChooseWorkspace()
  let port = eclim#client#nailgun#GetNgPort(workspace)

  call eclim#util#Echo("Removing interpreter...")
  let command = substitute(s:command_remove_interperter, '<path>', a:path, '')
  let result = eclim#ExecuteEclim(command, port)
  if type(result) == g:STRING_TYPE
    call eclim#util#Echo(result)
  endif
endfunction " }}}

function! eclim#python#project#GetInterpreters(folder) " {{{
  let workspace = eclim#eclipse#ChooseWorkspace(a:folder)
  let port = eclim#client#nailgun#GetNgPort(workspace)
  let results = eclim#ExecuteEclim(s:command_list_interperters, port)
  if type(results) != g:LIST_TYPE
    if type(results) == g:STRING_TYPE
      call eclim#util#EchoError(results)
    endif
    return
  endif
  return results
endfunction " }}}

function! s:InitPydev(folder) " {{{
  let interpreters = eclim#python#project#GetInterpreters(a:folder)
  if type(interpreters) != g:LIST_TYPE
    return 0
  endif

  if len(interpreters) == 0
    call eclim#util#EchoError(
      \ 'No python interpreters configured. Please use :PythonInterpreterAdd to add one.')
    return 0
  endif

  if len(interpreters) == 1
    let interpreter = interpreters[0].name
  else
    let answer = eclim#util#PromptList(
      \ "Please choose the interpreter to use",
      \ map(copy(interpreters), 'v:val.name'))
    if answer == -1
      return 0
    endif

    let interpreter = interpreters[answer].name
    redraw
  endif
  return '--interpreter ' . interpreter
endfunction " }}}

function! eclim#python#project#CommandCompleteInterpreter(argLead, cmdLine, cursorPos) " {{{
  let cmdLine = strpart(a:cmdLine, 0, a:cursorPos)
  let cmdTail = strpart(a:cmdLine, a:cursorPos)
  let argLead = substitute(a:argLead, cmdTail . '$', '', '')

  let workspace = eclim#eclipse#ChooseWorkspace()
  let interpreters = eclim#python#project#GetInterpreters(workspace)
  if !type(interpreters) == g:LIST_TYPE
    return []
  endif

  let names = map(interpreters, "v:val.path")
  if cmdLine !~ '[^\\]\s$'
    let argLead = escape(escape(argLead, '~'), '~')
    " remove escape slashes
    let argLead = substitute(argLead, '\', '', 'g')
    call filter(names, 'v:val =~ "^' . argLead . '"')
  endif

  call map(names, 'escape(v:val, " ")')
  return names
endfunction " }}}

" vim:ft=vim:fdm=marker
