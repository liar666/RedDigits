outDF <- read.csv("../trainset.csv", row.names = 1)

### TODO1: rajouter une non-linéarité en tronquant les val<seuil_min val>seuil_max??
###
### TODO2: utiliser tsne/pca/AttrSel pour mieux séparer les exemples??
##tsn <- tsne(outDF)
##plot(tsn, col=1:nrow(outDF))


######################### DATA VIZUALIZATION

library(MASS)    ## for // plots
parcoord(outDF, col=unique(outDF$class), var.label=TRUE)
legend(x="left", y="top", legend=rownames(outDF), col=1:nrow(outDF), lty=1, lwd=4)

library(plotrix)   ## for radial plots
#outDF2 <- outDF
#outDF2[,"whole_0_0"] <- outDF2[,"whole_0_0"]/10
radial.plot(outDF, rp.type="p", labels=colnames(outDF))


######################### CLUSTERING

outDF3 <- rbind(outDF, outDF[10,])
clust <- kmeans(x=outDF3, centers=10)
##plot(clust$cluster)
##radial.plot(outDF2, rp.type="p", labels=colnames(outDF), line.col=clust$cluster)
##pairs(outDF, col=clust$cluster)

### TODO3: utiliser des randomforest/SVM/NN!!!

######################### CLUSTER VIZUALIZATION

library(cluster)   ### to plot clusters in 2D, along 2 most important attributes
clusplot(outDF3, clust$cluster, color=TRUE, shade=TRUE, labels=2, lines=0)

##library(fpc)
##plotcluster(outDF, clust$cluster)



scaled <- scale(subsample)

# Test kmeans on raw data
clustr <- kmeans(x=subsample[,-19], centers=12)
plotcluster(subsample, clustr$cluster)
clusplot(subsample, clustr$cluster, color=TRUE, shade=TRUE, labels=2, lines=0)
# Test kmeans on scaled data
clusts <- kmeans(x=scaled[,-19], centers=12)
plotcluster(subsample, clusts$cluster)
clusplot(subsample, clusts$cluster, color=TRUE, shade=TRUE, labels=2, lines=0)

# Test SVM on raw data
library("e1071")
tuned <- tune.svm(class~., data=subsample, gamma=10^(-6:-1), cost=10^(-1:1))
summary(tuned)
model  <- svm(class~., data=subsample, kernel="radial", gamma=tuned$best.parameters$gamma, cost=tuned$best.parameters$cost)
summary(model)

# Try prediction on learing set
prediction <- round(predict(model, subsample[,-19]))
confmtx <- table(pred=prediction, true=subsample[,19])
confmtx
# All perfect!!! => overlearning???

# Try prediction on fullset
prediction <- round(predict(model, fullset[,-19]))
confmtx <- table(pred=prediction, true=fullset[,19])
# Lots of bad results :{

# Try prediction on testing set
prediction <- round(predict(model, subsample2[,-19]))
confmtx <- table(pred=prediction, true=subsample2[,19])
confmtx
