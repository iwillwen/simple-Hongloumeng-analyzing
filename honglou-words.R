library(ggplot2)

frequenciesFile <- file.path(".", "honglou-words-frequencies.txt")
outputPDF <- file.path(".", "honglou-output.pdf")

# Loading the words set processed by Go
words <- readLines(frequenciesFile, encoding = "UTF-8")
words <- strsplit(words, "\n")

# Find out the separations
seps <- sapply(1:length(words), function(index) if (words[index] == "---") index)
seps <- Filter(Negate(is.null), seps)
seps <- append(c(0), seps)

# Analyzing the frequencies of the words
frequencies <- list()

process1 <- function(i, lastIndex) {
  index <- seps[[i]]
  words.in.chap <- c()
  counts <- c()

  start <- lastIndex + 1
  end <- index - 1
  tmp.words <- words[start:end]

  for (ii in 1:length(tmp.words)) {
    if (typeof(tmp.words[[ii]]) == "character") {
      tuple <- strsplit(tmp.words[[ii]], " ")[[1]]
      words.in.chap <- append(words.in.chap, tuple[1])
      counts <- append(counts, as.integer(tuple[2]))
    }
  }

  df <- data.frame(Word = words.in.chap, Count = counts)
  df <- df[ order(-df[,2]),  ]

  return(df)
}

lastIndex <- 0
for (i in 2:length(seps)) {
  lastIndex <- seps[i - 1][[1]]
  rtn <- process1(i, lastIndex = lastIndex)
  frequencies[[length(frequencies)+1]] <- rtn
}

df <- data.frame(Word = c(), Count = c(), Chap = c())

# Take the top 200 words from each chapters
# and merge them into a data frame
for (i in 1:length(frequencies)) {
  frequencies[[i]]["Chap"] <- i
  df <- rbind(df, head(frequencies[[i]], 200))
}

# Drawing the outout graph
p <- ggplot(df, aes(x=Word, y=Count, color=Count, size=Count))
p <- p + facet_wrap(~Chap, nrow=2)
p <- p + geom_smooth(aes(group = 1), level = 0.9999)
p <- p + geom_smooth(aes(group = 1), method="lm")
p <- p + geom_point() + scale_y_log10()
p <- p + scale_x_discrete(labels=NULL)
p <- p + theme_bw(16)
p <- p + ggtitle("Hong Lou Meng - From Chapter 77 to Chapter 84")
p <- p + theme(plot.title = element_text(lineheight=1.2))
p <- p + ggsave(outputPDF, width=13, height=8.5)
