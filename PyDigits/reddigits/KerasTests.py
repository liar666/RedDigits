#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pieces of code for Keras
"""


##### Basic
from keras.models import Sequential
from keras.layers import Dense
data = np.random.random((1000,100))
labels = np.random.randint(2,size=(1000,1))
model = Sequential()
model.add(Dense(32,
activation='relu',
input_dim=100))
model.add(Dense(1, activation='sigmoid'))
model.compile(optimizer='rmsprop',
loss='binary_crossentropy',
metrics=['accuracy'])
model.fit(data,labels,epochs=10,batch_size=32)

##### MultiClass
from keras.layers import Dropout
model.add(Dense(512,activation='relu',input_shape=(784,)))
model.add(Dropout(0.2))
model.add(Dense(512,activation='relu'))
model.add(Dropout(0.2))
model.add(Dense(10,activation='softmax'))
# compile1
model.compile(optimizer='rmsprop', loss='categorical_crossentropy', metrics=['accuracy'])

##### Convolutional
from keras.layers import Activation,Conv2D,MaxPooling2D,Flatten
model2.add(Conv2D(32,(3,3),padding='same',input_shape=x_train.shape[1:]))
model2.add(Activation('relu'))
model2.add(Conv2D(32,(3,3)))
model2.add(Activation('relu'))
model2.add(MaxPooling2D(pool_size=(2,2)))
model2.add(Dropout(0.25))
model2.add(Conv2D(64,(3,3), padding='same'))
model2.add(Activation('relu'))
model2.add(Conv2D(64,(3, 3)))
model2.add(Activation('relu'))
model2.add(MaxPooling2D(pool_size=(2,2)))
model2.add(Dropout(0.25)
model2.add(Flatten())
model2.add(Dense(512))
model2.add(Activation('relu'))
model2.add(Dropout(0.5))
model2.add(Dense(num_classes))
model2.add(Activation('softmax'))

##### RNN
from keras.klayers import Embedding,LSTM
model3.add(Embedding(20000,128))
model3.add(LSTM(128,dropout=0.2,recurrent_dropout=0.2))
model3.add(Dense(1,activation='sigmoid')
# compile2
model3.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])


# fit
model3.fit(x_train4, y_train4, batch_size=32, epochs=15, verbose=1, validation_data=(x_test4,y_test4))

# predict
model3.predict(x_test4, batch_size=32)
model3.predict_classes(x_test4,batch_size=32)

# Save/Reload
from keras.models import load_model
model3.save('model_file.h5')
my_model = load_model('my_model.h5')

# evaluate
score = model3.evaluate(x_test, y_test, batch_size=32)

