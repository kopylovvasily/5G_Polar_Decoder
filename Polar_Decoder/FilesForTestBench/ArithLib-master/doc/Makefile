TARGET = ArithLibraryUsersGuide.pdf
EPSFIGURES = ArithLibStatistics.eps LoggerPlotLabeled.eps

LATEX = latex-2008
DVIPDF = dvipdf

.PHONY: all clean

all: $(TARGET)

%.pdf: %.tex $(EPSFIGURES)
	$(LATEX) $<
	$(LATEX) $<
	$(LATEX) $<
	$(DVIPDF) $*

clean:
	rm -f *.aux
	rm -f *.log
	rm -f *.dvi
