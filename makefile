MD_DIR=_articles
SRC_DIR=scripts

HTML_DIR=$(MD_DIR)/html
ANA_DIR=$(MD_DIR)/analysis

ANA=$(wildcard $(ANA_DIR)/*.md)
HTML=$(addprefix $(HTML_DIR)/,$(notdir $(ANA:.md=.html)))
MD=$(addprefix $(MD_DIR)/,$(notdir $(ANA)))
MASTER=$(shell git ls-tree -r --name-only --full-tree master)
PHONY_TARGETS=$(notdir $(ANA:.md=))

DL_PY=$(SRC_DIR)/download.py
BD_PY=$(SRC_DIR)/build.py
CONF=$(SRC_DIR)/config.py

.PHONY: $(PHONY_TARGETS) clean rebuild download force-download test

all: $(MD)

$(MD_DIR)/%.md:$(ANA_DIR)/%.md $(BD_PY) $(CONF)
	@id=$(notdir $(basename $@));                                           \
	c=$${id:0:1};                                                           \
	index=$${id:1:4};                                                       \
	case $$c in                                                             \
	'a')                                                                    \
	    codefile=PATAdvanced/$$index.c;                                     \
	    ;;                                                                  \
	'b')                                                                    \
	    codefile=PATBasic/$$index.c;                                        \
	    ;;                                                                  \
	't')                                                                    \
	    codefile=PATTop/$$index.c;                                          \
	    ;;                                                                  \
	*)                                                                      \
	    echo file name wrong: $@;                                           \
	esac;                                                                   \
	if [[ "$(MASTER)" == *$$codefile* ]]; then                              \
	    for f in $^; do                                                     \
	        if [ ! -f $$f ]; then                                           \
	            echo $$f is missing;                                        \
	        else                                                            \
	            python $(SRC_DIR)/build.py -o $$id; break;                  \
	        fi;                                                             \
	    done;                                                               \
	else                                                                    \
	    echo $$codefile not exist;                                          \
	fi

$(ANA_DIR)/%.md:
	touch $@

$(HTML_DIR)/%.html: $(DL_PY)
	python $(SRC_DIR)/download.py $(notdir $(basename $@))

clean:
	rm -f $(MD)

rebuild: clean all

download:
	python $(SRC_DIR)/download.py

force-download:
	python $(SRC_DIR)/download.py -f

test:
	@echo -e $(PHONY_TARGETS)