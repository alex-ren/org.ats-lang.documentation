.. Document for Model Checking ATS

Model Checking ATS
=====================================

In this project, we focus on integrating model checking techniques seamlessly into
the development of ATS program. Before going to the details, let's have a quick look
of the process of verifying a concurrent ATS program.

First of all, we provide a library with support for concurrent programming such
as creating new threads, synchronization primitives (mutex, condition), and etc. 
All these supports are given appropriate types in ATS to reduce the possibilities
of ill usage. 


.. literalinclude:: 16_reader_writer.dats
  :language: text
  :linenos:




