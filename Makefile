## Parameters ##################################################################
SRC_DIR ?= ${CURDIR}/src/
BIN_DIR ?= ${CURDIR}/bin/
LIB_DIR ?= ${CURDIR}/lib/
TMP_DIR ?= /tmp/hastabel_standalone.jar.build/

TARGET ?= hastabel.jar
STANDALONE ?= hastabel_standalone.jar
INSTALL_DIR ?= $(LIB_DIR)

#### Where to get the missing Jar files.
JAR_SOURCE ?= "https://noot-noot.org/tabellion/jar/"

#### Binaries
###### JAR binary
JAR ?= jar

###### JRE binary
JAVA ?= java

###### JDK binary
JAVAC ?= javac

###### ANTLR
ANTLR_JAR ?= $(LIB_DIR)/antlr-4.7-complete.jar

##### Downloader
DOWNLOADER ?= wget

## Parameters Sanity Check #####################################################
ifeq ($(strip $(JAVA)),)
$(error No Java executable defined as parameter.)
endif

ifeq ($(strip $(JAVAC)),)
$(error No Java compiler defined as parameter.)
endif

ifeq ($(strip $(ANTLR_JAR)),)
$(error No ANTLR_JAR defined as parameter.)
endif

## Java Config #################################################################
CLASSPATH = "$(SRC_DIR):$(BIN_DIR):$(ANTLR_JAR)"

## Makefile Magic ##############################################################
ANTLR_SOURCES = $(wildcard $(SRC_DIR)/hastabel/*.g4)
JAVA_SOURCES = \
	$(filter-out $(ANTLR_SOURCES:.g4=.java), \
		$(wildcard $(SRC_DIR)/hastabel/*.java) \
		$(wildcard $(SRC_DIR)/hastabel/*/*.java) \
	)\
	$(ANTLR_SOURCES:.g4=.java)
CLASSES = $(patsubst $(SRC_DIR)/%,$(BIN_DIR)/%, $(JAVA_SOURCES:.java=.class))

## Makefile Rules ##############################################################
$(STANDALONE): $(TMP_DIR) $(TARGET) $(ANTLR_JAR)
	unzip -d $(TMP_DIR) -uo $(TARGET)
	unzip -d $(TMP_DIR) -uo $(ANTLR_JAR)
	jar -cvf $@ -C $(TMP_DIR) .

$(TARGET): $(ANTLR_JAR) $(JAVA_SOURCES) $(CLASSES)
	rm -f $(TARGET) $(INSTALL_DIR)/$@
	$(JAR) cf $@ -C $(BIN_DIR) .
	cp $@ $(INSTALL_DIR)/$@

clean:
	rm -f $(filter-out $(ANTLR_SOURCES),$(wildcard $(ANTLR_SOURCES:.g4=*)))
	rm -rf $(BIN_DIR)/*
	rm -f $(TARGET)

$(SRC_DIR)/hastabel/LangParser.java: $(ANTLR_SOURCES)

$(SRC_DIR)/hastabel/PropertyParser.java: $(ANTLR_SOURCES)

# Pattern rules can be used to generate multiple target in a single action.
LangLexer%java LangParser%java PropertyLexer%java PropertyParser%java: $(ANTLR_SOURCES)
	$(JAVA) -jar $(ANTLR_JAR) -lib $(SRC_DIR)/hastabel/ $^

$(CLASSES): $(BIN_DIR)/%.class: $(SRC_DIR)/%.java $(BIN_DIR)
	$(JAVAC) -cp $(CLASSPATH) -d $(BIN_DIR) $<

%.jar:
	$(MAKE) $(LIB_DIR)
	echo "Attempting to download missing jar '$@'..."
	cd $(LIB_DIR); $(DOWNLOADER) "$(JAR_SOURCE)/$(notdir $@)"

$(TMP_DIR):
	mkdir -p $@

$(LIB_DIR):
	mkdir -p $@

$(BIN_DIR):
	mkdir -p $@

##### For my private use...
publish: $(TARGET) $(STANDALONE)
	scp $^ dreamhost:~/noot-noot/tabellion/jar/
