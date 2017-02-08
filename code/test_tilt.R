library("EBImage")

img <- readImage("/home/gmuller/Downloads/RedDigits/images/numbers/4.png")
imgSize <- dim(img)


## http://homepages.inf.ed.ac.uk/rbf/HIPR2/affine.htm
for(t in seq(from=-.3,to=.3,by=.05)) {
    tilt <- matrix(c(1,t,-t*imgSize[[1]],0,1,0), ncol=2)
    img2 <- affine(x=img, m=tilt)
    display(img2)
    Sys.sleep(1)
}
