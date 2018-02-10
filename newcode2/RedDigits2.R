source("TrainSet.R");

library("keras");

OUT_DIR <- "/home/gmuller/Perso/RedDigits/newcode2/Models/"

## Load data
load(p(OUTDIR_TRAINSET, "splitted/train+testWhole.RData"))
train <- train[,c(-1)];
test  <- test[,c(-1)];

dataCols  <- grep("^i",colnames(test));
classCols <- grep("^c",colnames(test));

## Prepare model
modelKeras1 <- keras_model_sequential()
modelKeras1 %>%
   layer_dense(units = 256, activation = 'relu', input_shape = c(420)) %>%
   layer_dropout(rate = 0.4) %>%
   layer_dense(units = 128, activation = 'relu') %>%
   layer_dropout(rate = 0.3) %>%
   layer_dense(units = 13, activation = 'softmax')
summary(modelKeras1)
modelKeras1 %>% compile(
   loss = 'categorical_crossentropy',
   optimizer = optimizer_rmsprop(),
   metrics = c('accuracy')
 )

## Train model
history <- modelKeras1 %>% fit(
   as.matrix(train[,-classCols]), as.matrix(train[,classCols]),
   epochs = 30, batch_size = 10,
   validation_split = 0.2
 )

## Evaluate model
plot(history)
modelKeras1 %>% evaluate(as.matrix(test[,-classCols]), as.matrix(test[,classCols]))

## Use model
modelKeras1 %>% predict_classes(as.matrix(test[,-classCols]))

## Save model both in RData & HDF5 formats
fileName <- p(OUT_DIR, "RedDigitModel_Keras1")
Rmodel <- serialize_model(modelKeras1, include_optimizer = TRUE)
save(Rmodel, file=p(fileName,".RData"))
save_model_hdf5(modelKeras1, p(fileName,".hdf5"), overwrite = TRUE, include_optimizer = TRUE)

## Attempt reloading model from both RData & HDF5 formats
load(file=p(fileName,".RData")) # overrides Rmodel
model2 <- unserialize_model(Rmodel, custom_objects = NULL, compile = TRUE)
modelHDF5 <- load_model_hdf5(p(fileName,".hdf5"), custom_objects = NULL, compile = TRUE)
