.. Document for ATS TAG generator.
   Starting Date: 09/03/2013

Tag Generator For ATS-Anairiats
==================================

Description
-----------
For users of Emacs and Vim, it is common to browse source code spanning over
multiple files with the support of *tag*. Here, we proivde a tool for generating
*tag* files accepted by these two editors.

Download
----------
Please download the file :download:`ats-lang-tools.jar </_static/atstools/taggen/ats-lang-tools.jar>`.

Usage
-------
The generation of *tag* file includes two steps as follows.

#.  Use *atsopt* to collect information from the source files you have.

    .. code-block:: bash

        atsopt -o MYTAGS --taggen -s fact.sats -d fact.dats

#.  Use *atstools.jar* to generate the tag file from *MYTAGS*.

    .. code-block:: bash

        java -jar atstools.jar --input MYTAGS -c --output tags # "c" for ctags with vim
        java -jar atstools.jar --input MYTAGS -e --output TAGS # "e" for etags with emacs

The next example shows how to generate the tag file for the source files of ATS-Postiats.
*atsopt* would output to file *MYTAGS* accululatively, so we can combine *find* and *atsopt*
to generate a large *MYTAGS*.

    .. code-block:: bash

        # Assume we are in the root directory of the repository of ATS-Postiats.
        # Make sure we start from a clean slate.
        rm -f MYTAGS

        find ./src -name "*.sats" -exec atsopt -o MYTAGS --taggen -s {} \;
        find ./src -name "*.dats" -exec atsopt -o MYTAGS --taggen -d {} \;
        java -jar atstools.jar --input MYTAGS -c --output tags



Development
------------
The project is held on Github with the follwing address https://github.com/alex-ren/org.ats-lang.toolats.



