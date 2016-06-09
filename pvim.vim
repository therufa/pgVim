"
" Postgresql functions for VIM editor
"

let s:bash = "/bin/bash"
let s:psql = "/usr/bin/psql"

let s:host = 'localhost'
let s:usr  = ''
let s:passwd = ''
let s:db = ''
let s:port = 5432

" Basic value assignment
function! PSQLInit( args )
    if has_key(a:args, 'host')
        let s:host = a:args['host']
    endif

    if has_key(a:args, 'port')
        let s:port = a:args['port']
    endif

    if has_key(a:args, 'usr')
        let s:usr = a:args['usr']
    endif

    if has_key(a:args, 'passwd')
        let s:passwd = a:args['passwd']
    endif

    if has_key(a:args, 'db')
        let s:db = a:args['db']
    endif
endfunction

" Building connect string
" Rerurns string
function! _PSQLBuildConnectString()
    let result = ''

    if ! empty(s:host)
        let result = result . " --host=".s:host
    endif

    if ! empty(s:port)
        let result = result . " --port=".s:port
    endif

    if ! empty(s:passwd)
        let result = result . " --password=".s:passwd
    else
        let result = result . " --no-password"
    endif

    if ! empty(s:usr)
        let result = result . " --username=".s:usr
    endif

    if ! empty(s:db)
        let result = result . " --dbname=".s:db
    endif

    return result
endfunction

" Read entire table from database into the current VIM session
function! PSQLCopyTable( table, ... )
    " Define target table
    let table       = a:table

    " Conditional varaiables 
    let database    = s:db
    let clear       = 0

    " Override default database 
    if ( len(a:000) >= 1 )
        let s:db = a:1
    endif

    " Wipe the whole content, and insert content at the beginning of the file
    if ( len(a:000) == 2 )
        let clear = a:2
    endif

    " Bulding the query string
    let connStr = _PSQLBuildConnectString()

    " Store the query result in a register
    let result = system(s:psql.' -c "COPY '.table.' TO stdout;"'.connStr)
    let pos = 0

    " Clear file
    if clear == 1
        :%d
    endif

    for row in split(result, "\n")
        if ! empty(row)
            execute append(pos, row)
            let pos += 1
        endif
    endfor
endfunction

" Save the current VIM session into target table
" WARNING! Target table gets truncated before content gets stored
function! PSQLCopySave( table, ... )
    let table       = a:table
    let RND = Random() 

    " Conditional varaiables 
    let database    = s:db
    let cache_file  = '/tmp/vimPSQL.'.RND.'.cache'

    " Override database
    if ( len(a:000) >= 1 )
        let s:db = a:1
    endif

    " Set custom cache_file
    if ( len(a:000) >= 2 )
        let cache_file = a:2
    endif

    " Declaring vars 
    let result = ''
    let pos = 0
    let end_pos = line('$')
    let buff_line = ''
    let strBuff_out = ''
    let line_separator = ''

    " Loop through session
    while ( pos <= end_pos )
        let buff_line = getline(pos)
        let buff_line = substitute(buff_line,"\t",'\t','')

        " Appending new line characher
        if ! empty(getline(pos+1))
            let line_separator = "\n"
        endif

        " Appending value to buffer
        if ! empty(buff_line)
            let strBuff_out = strBuff_out.line_separator."echo \"".buff_line."\""
        endif

        let pos += 1
    endwhile

    " Building query string
    let query_string = "echo \"BEGIN; TRUNCATE ".table."; COPY ".table." FROM stdin;\""
    let query_string = query_string.strBuff_out."\necho \"\\.\"\necho \"COMMIT;\"\n"

    let arrBuff_out = split(query_string, "\n", 1)

    " Create an executale file
    call writefile(arrBuff_out, cache_file)

    let connStr = _PSQLBuildConnectString()
    let result = system(s:bash.' '.cache_file.'|'.s:psql.' -f - '.connStr.';rm -f '.cache_file)

    " Print query messages
    echo result
endfunction
