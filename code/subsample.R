fullset <- read.csv("../trainsets/trainset_full.csv")
fullset <- fullset[,c(-1,-2)]
# class 0->9+EH -> 1->12
fullset[,c("class")] <- as.numeric(fullset[,c("class")])
head(fullset)

subsample <- rbind(fullset[fullset[,"class"]==1,][0:50,] ,
                   fullset[fullset[,"class"]==2,][50:100,] ,
                   fullset[fullset[,"class"]==3,][100:150,] ,
                   fullset[fullset[,"class"]==4,][150:200,] ,
                   fullset[fullset[,"class"]==5,][200:250,] ,
                   fullset[fullset[,"class"]==6,][250:300,] ,
                   fullset[fullset[,"class"]==7,][0:50,] ,
                   fullset[fullset[,"class"]==8,][100:150,] ,
                   fullset[fullset[,"class"]==9,][150:200,] ,
                   fullset[fullset[,"class"]==10,][50:100,] ,
                   fullset[fullset[,"class"]==11,][0:50,] ,
                   fullset[fullset[,"class"]==12,][200:250,] )
dim(subsample)
subsample <- subsample[,-1]
write.csv(x=subsample, file="../trainsets/subsample.csv", row.names = TRUE)

subsample2 <- rbind(fullset[fullset[,"class"]==1,][50:100,] ,
                    fullset[fullset[,"class"]==2,][150:200,] ,
                    fullset[fullset[,"class"]==3,][50:100,] ,
                    fullset[fullset[,"class"]==4,][100:150,] ,
                    fullset[fullset[,"class"]==5,][250:300,] ,
                    fullset[fullset[,"class"]==6,][150:200,] ,
                    fullset[fullset[,"class"]==7,][100:150,] ,
                    fullset[fullset[,"class"]==8,][0:50,] ,
                    fullset[fullset[,"class"]==9,][0:50,] ,
                    fullset[fullset[,"class"]==10,][150:200,] ,
                    fullset[fullset[,"class"]==11,][100:150,] ,
                    fullset[fullset[,"class"]==12,][100:150,] )
dim(subsample2)
subsample2 <- subsample2[,-1]
write.csv(x=subsample2, file="../trainsets/subsample2.csv", row.names = TRUE)



subsample <- read.csv("../trainsets/subsample.csv")
subsample <- subsample[,-1]
subsample[,c("class")] <- as.numeric(subsample[,c("class")])

scale(subsample)
