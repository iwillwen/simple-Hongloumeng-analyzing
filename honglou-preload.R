library(jiebaR)

inputFile <- file.path(".", "honglou.txt")
outputFile <- file.path(".", "honglou-words.txt")

# Load the raw Hongloumeng text
text <- readLines(inputFile, encoding = "UTF-8")
text <- text[!text == ""]
lines <- strsplit(text, "\r\n")

# Find the chapter title
chapsLineNum <- sapply(lines, function(line) grep("^\u7b2c", line[1]))
chapsLineNum <- sapply(1:length(chapsLineNum), function(i) ifelse(chapsLineNum[[i]] == 1, i, NA))
chapsLineNum <- Filter(function(x) x[1] > 0, chapsLineNum)

# Front 80 chapters and Behind 40 chapters
chapsLineNumPrev <- chapsLineNum[1:80]
chapsLineNumNext <- chapsLineNum[81:120]

testChapsLineNum <- chapsLineNum[77:85]

# Ignore the punctuations
ignoreChar <- c("\u3000", "\uff1a", "\uff1f", "\uff1b", "\u201c", "\u201d", "\u3002", "\uff0c", "\u2026", "\u2500", "\u3001", "\u300a", "\u300b", "\uff01")
ignore <- function(s) {
  for (i in 1:length(ignoreChar)) {
    s <- gsub(ignoreChar[i], " ", s)
  }
  
  return(s)
}

# Segment the text
sapply(1:(length(testChapsLineNum) - 1), function(i) {
  end <- length(lines)
  if ((i + 1) <= length(testChapsLineNum)) {
    end <- testChapsLineNum[[i + 1]] - 1
  }
  
  thisLines <- lines[testChapsLineNum[[i]]:end]
  thisLines.tags <- sapply(thisLines, function(line) {
    mixseg = worker()
    # Segment
    tags <- mixseg <= ignore(line)

    write(paste(tags, collapse = ","), outputFile, append = TRUE)
    return(tags)
  })
  
  write("#", outputFile, append = TRUE)
})
