library(EBImage)

XMAX=100
YMAX=100

img <- matrix(nrow=YMAX,ncol=XMAX,0)
img[10:20, 10:10] <- 1
img[20:40, 20:30] <- 2
img[50:60, 50:60] <- 3

I <- Image(img, c(XMAX,YMAX), "Grayscale")
display(I)

inds <- which(img > 0, arr.ind = T);



shapes <- readImage(system.file('images', 'shapes.png', package='EBImage'))
logo <- shapes[110:512,1:130]
display(logo)

logo_label <- bwlabel(logo)
table(logo_label)
