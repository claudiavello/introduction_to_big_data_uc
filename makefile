# Makefile for letter frequency task
# Author: Claudia Vello

OUTPUT = LittleWomen.lfr

all: $(OUTPUT)

$(OUTPUT): letter_frequency.sh
	@chmod +x letter_frequency.sh
	@echo "Running letter frequency script..."
	./letter_frequency.sh

clean:
	rm -f $(OUTPUT) shell-lesson-data.zip
