.PHONY: all clean

# Default target
all: NikOgura.pdf

NikOgura.pdf: NikOguraResumeShortForm.md resume-template.latex resume.cls
	pandoc -f markdown -t pdf -o $@ $< --template=resume-template.latex

clean:
	rm -f NikOgura.pdf
