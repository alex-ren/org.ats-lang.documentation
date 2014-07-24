.. Document for usage of ATS staload with variables.
   Starting Date: 05/15/2014

Syntax for *staload*
======================

Description
------------
In **ATS2**, keyword *staload* is followed by a literal string, which specifies the location of the
file to be loaded. Besides those relative path and absolute path commonly seen, we can use *macro*
inside the literal string. One example goes as follows:

.. code-block:: none 

   staload "{$GTK}/SATS/gdk.sats"

The *GTK* is not a system environment variable. It is actually a macro defined somewhere. For
example, we can use the following code to set the *GTK* to the directory containing **ATS2** code for gdk
library.

.. code-block:: none

   #define GTK_targetloc "~/codebase/contrib/GTK"
   staload "{$GTK}/SATS/gdk.sats"

Or we can use macros inside **ATS2** compiler, such as the following:

.. code-block:: none

   #define GTK_targetloc "$PATSHOMERELOC/contrib/GTK"

The macro *PATSHOMERELOC* in **ATS2** compiler is from the environment variable *PATSHOMERELOC*, which
is set in the environment before executing *patscc* or *patsopt*.

Going further, let's have a look of the file **$PATSHOME/share/HATS/atspre_define_pdgreloc.hats**, which is
included by the file **$PATSHOME/share/atspre_define.hats**, which is commonly included in almost
all *dats* files.

.. code-block:: none

   //
   #define
   ZLOG_targetloc "$PATSHOMERELOC/contrib/zlog"
   //
   #define
   JSONC_sourceloc "$PATSLIB_URL/contrib/json-c"
   #define
   JSONC_targetloc "$PATSHOMERELOC/contrib/json-c"

As we can see, by default **ATS2** compiler would try locating the source files for *zlog* and
*json-c* library in the *contrib* directory.



