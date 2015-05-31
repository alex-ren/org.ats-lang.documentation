
#Makefile for untyped lambda calculus
######

include $(PATSHOME)/share/atsmake-pre.mk


######
#
CFLAGS += -O2
#
######
#
# TODO
#LDFLAGS :=  # uncomment this for a clean start of LDFLAGS
# LDFLAGS += -lm  # uncomment this for math library
# 
# TODO
# Uncomment the following if you want the Boehm GC.
# By default, MALLOCFLAG is -DATS_MEMALLOC_LIBC
# LDFLAGS += -lgc
# MALLOCFLAG := -DATS_MEMALLOC_GCBDW
#
######

# TODO
# Add source files here.
SOURCES_DATS += UTLC.dats
SOURCES_SATS +=
SOURCES_C    += 

# TODO
# Specify the name of the target.
TARGET=UTLC

MYTARGET=$(TARGET)


include $(PATSHOME)/share/atsmake-post.mk

######

######

cleanats:: ; $(RMF) *_?ats.c

cleanall:: ; $(RMF) $(TARGET)

######

######


# For the future when tag generator is provided.
# .PHONY: tags
# tags:
# 	$(RMF) tags MYTAGS
# 	find ./ -name "*.sats" -exec $(PATSOPT) --output-a MYTAGS --taggen -s {} \;
# 	find ./ -name "*.dats" -exec $(PATSOPT) --output-a MYTAGS --taggen -d {} \; 
# 	java -jar ../../../tool/ats-lang-tools.jar --input MYTAGS -c --output tags

###### end of [Makefile] ######

