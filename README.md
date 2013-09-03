PostgreSQL macros for VIM:
==========================

This package contains a couple of Vim macros you can use to edit data stored in
a PostgreSQL database directly in Vim.


How to use it:
--------------

Just put the functions provided by this package into your .vimrc and enjoy the
following 3 procedures:

:call PSQLInit({'host': <host>, 'port': …, 'db': …, 'usr': …, 'passwd': …, })
:call PSQLCopyTable( 't_test', [ 'db', [, truncfile: 0 ]]
:call PSQLCopySave('t_test' [, 'db'])

PSQLInit will initialize Vim to know about your connect strings and so on.
Then you can call PSQLCopyTable to load the entire content of a table from
PostgreSQL to Vim.
Data will be available in COPY format (tab separated) so that you can easily
modify data as you like.
Once you are done editing you can call PSQLCopySave to replace the entire
content of the table you are working on with the set of data in your editor.

NOTE: While you edit you data in Vim it will not be locked in PostgreSQL. This
means that if 2 people chose to edit the same table concurrently there is no
interlocking. You should really only do it when nobody else is on the system or
when you are dealing with static data.

-----------------------------------------------------------------------------
Max Attila Ruf and Hans-Jürgen Schönig, 2013
Cybertec Schönig & Schönig GmbH

www.postgresql-support.de
