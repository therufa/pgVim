" getting pseudorandom number
" Script written by Botykai Zsolt http://stackoverflow.com/users/11621/zsolt-botykai

let g:rnd = localtime() % 0x10000 

function! Random() 
  let g:rnd = (g:rnd * 31421 + 6927) % 0x10000 
  return g:rnd 
endfun 

function! Choose(n) " 0 n within 
  return (Random() * a:n) / 0x10000 
endfun 
