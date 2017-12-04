library(stringr)
library(httr)
library(jsonlite)
library(jpeg)
library(purrr)

dir.create("img", showWarnings = FALSE)

card_names <- readLines("fifteen_card_highlander.txt")

for (n in card_names) {
  path <- paste0("cards/named?exact=", str_replace_all(n, " ", "+"))
  res <- GET(url = "https://api.scryfall.com/", path = path)
  content <- rawToChar(res$content)
  image_url <- fromJSON(content)$image_uris$large
  download.file(image_url, file.path("img", paste0(str_replace_all(n, "\\/", "-"), ".jpg")))
}


# load all JPG card images
imgs <- list.files("img", "*.jpg", full.names = TRUE) %>% map(~ readJPEG(.))

# split the vector of images into "pages" (9 images per page)
pages <- split(imgs, ceiling(seq_along(card_names) / 9))

pdf("cards.pdf", paper="a4")
par(mai = rep(0,4), bg = "black")
layout(matrix(1:9, ncol=3, byrow=TRUE))

# iterate over all images in all pages and plot them
for (page in pages) {
  for (card in page) {
    plot(NA, xlim = 0:1, ylim = 0:1, bty = "n", axes = 0, xaxs = "i", yaxs = "i")
    rasterImage(card, 0, 0, 1, 1)
  }
}

dev.off()
