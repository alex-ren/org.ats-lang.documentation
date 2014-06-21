#
# A simple Makefile
#

######

PATSCC=patscc
PATSOPT=patsopt

######

%: %.sats ; $(PATSCC) -tcats $<

######

%: %.dats ; \
$(PATSCC) -O2 -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o $@ $<

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

cleanall:: clean
cleanall:: ; $(RMF) demo_print

######

###### end of [Makefile] ######
