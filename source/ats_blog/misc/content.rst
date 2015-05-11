.. Miscellaneous topics related to the installation of ATS2.

Miscellaneous topics related to ATS-Postiats
==============================================

Setting of Environment
-----------------------

Please follow the instructions on `ATS' website`_ to install *ATS-Postiats* as well as
*ATS2-contrib*. Here I just want to emphasize the setting of environment
variables *PATSHOME* as well as *PATSHOMERELOC*. These two variables should be
set in the environment before invoking the ATS compiler (*patscc* or *patsopt*).
Also they are commonly referred in *Makefile* used in ATS projects. The first
one (*PATSHOME*) should be set to the directory where ATS is installed. Normally I just
download tarball for the source of ATS, decompress it, build ATS, and use
built executables. (Simply put, I don't do ``make install``.) 
Therefore I just set *PATSHOME* to the folder resulting from
decompressing the tarball. *PATSHOMERELOC* should be set to the folder
resulting for decompress the tarball for *ATS2-contrib*. Also the *PATH*
variable should be set accordingly so that system can locate the compiler of
ATS. Normally, I put these settings into one script file, say *pats.xxx.sh*.
Then I do ``source pats.xxx.sh`` when I open a terminal for the first time.
My *pats.xxx.sh* looks like the following:

.. literalinclude:: pats.xxx.sh
   :language: bash

If you use ``make install`` to install ATS at the system level, your script would probably be
like the following:

.. literalinclude:: pats.installed.sh
   :language: bash

.. note::

   Since we choose to install ATS at the system level, there's no need to set *PATH*.


.. _ATS' website: http://www.ats-lang.org/DOWNLOAD/#installation_srccomp

Usage of *staload*
--------------------------

Some useful information about *staload* can be found in 
`Wiki <https://github.com/githwxi/ATS-Postiats/wiki/staload>`_ and my previous 
`blog <https://groups.google.com/forum/#!msg/ats-lang-users/4_d_tmGZXIA/8Hc7kMLfsesJ>`_.


Standard *header* files
--------------------------

To use the *prelude* library of ATS, we would include the following code:

.. code-block:: none
   
   #include "share/atspre_define.hats"
   #include "share/atspre_staload.hats"

To use the *ML* library of ATS, we would include the following code:

.. code-block:: none

   #include "share/HATS/atspre_staload_libats_ML.hats"

If we want to generate C code used on lower level systems, such as embedded system, 
we can replace these *header* files with appropriate ones to fit the targeting
platform.

Type conversion
-----------------

.. todo::

   * ``$UNSAFE.cast{natLt(n)}``





