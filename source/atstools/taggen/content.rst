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

#.  Use *ats-lang-tools.jar* to generate the tag file from *MYTAGS*.

    .. code-block:: bash

        java -jar ats-lang-tools.jar --input MYTAGS -c --output tags # "c" for ctags with vim
        java -jar ats-lang-tools.jar --input MYTAGS -e --output TAGS # "e" for etags with emacs

The next example shows how to generate the tag file for the source files of ATS-Postiats.
Using option *--output-a*, *atsopt* would output to file *MYTAGS* accululatively, so we can combine *find* and *atsopt*
to generate a large *MYTAGS*.

    .. code-block:: bash

        # Make sure we start from a clean slate.
        rm -f MYTAGS

        find ${PATSHOME}/src -name "*.sats" -exec atsopt --output-a MYTAGS --taggen -s {} \;
        find ${PATSHOME}/src -name "*.dats" -exec atsopt --output-a MYTAGS --taggen -d {} \;
        java -jar ats-lang-tools.jar --input MYTAGS -c --output tags

I use *${PATSHOME}/src* in the *find* command so that the generated *tags* would use absolute
path for each file. In this way, we can open vim at any location.

The aforementioned method can be applied to ATS-Postiats as well. The following example shows
how to generate the tag file for source files in the *prelude* of ATS-Postiats, which are written in ATS-Postiats.

    .. code-block:: bash

        PATH_PRELUDE=${PATSHOME}/prelude
        MYTAGS_PATS_PRELUDE_PATS=${PATH_PRELUDE}/MYTAGS_PATS_PRELUDE_PATS
     
        rm -rf ${MYTAGS_PATS_PRELUDE_PATS}
        # Exclude two subdirectories "CODEGEN" and "DOCUGEN"
        find ${PATH_PRELUDE}/SATS \( -name "CODEGEN" -o -name "DOCUGEN" \) -prune -o -name "*.sats" \
          -exec patsopt --output-a ${MYTAGS_PATS_PRELUDE_PATS} --taggen -s {} \;
        find ${PATH_PRELUDE}/DATS \( -name "CODEGEN" -o -name "DOCUGEN" \) -prune -o -name "*.dats" \
          -exec patsopt --output-a ${MYTAGS_PATS_PRELUDE_PATS} --taggen -d {} \;

        java -jar ${PATSHOME}/ats-lang-tools.jar -c --input ${MYTAGS_PATS_PRELUDE_PATS} --output ${PATH_PRELUDE}/tags
     



Development
------------
The project is held on Github with the follwing address https://github.com/alex-ren/org.ats-lang.toolats.



