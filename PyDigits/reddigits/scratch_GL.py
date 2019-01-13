############################
import skimage

tiltRange  = [t/10 for t in range(4, 4+1, 2)]  
angleRange = range(-30, 30+1, 15)
xTranslRange = [x*28 for x in range(-10, 10+1, 5)]
yTranslRange = [y*28 for y in range(-10, 10+1, 5)]
blurRange = [s/10 for s in range(1, 21+1, 5)]
zoomRange = [z/10 for z in range(6, 10+1, 1)]

print(blurRange)

############################

import pydrive
help(pydrive)

############################

from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from google.colab import auth
from oauth2client.client import GoogleCredentials

# 1. Authenticate and create the PyDrive client.
auth.authenticate_user()
gauth = GoogleAuth()
gauth.credentials = GoogleCredentials.get_application_default()
drive = GoogleDrive(gauth)

############################

#2. Get the file
downloaded = drive.CreateFile({'id':'1p-ywiyItmK_hTGZxpOnempdKMy3eYefz'}) # replace the id with id of file you want to access
downloaded.GetContentFile('image.jpg')  

#3. Read file as panda dataframe
import skimage
from skimage import io
im = io.imread('image.jpg')


############################


import matplotlib
import matplotlib.pyplot as plt

from skimage import filters, exposure

im_blurred = im.copy()
print(im.shape)
im_blurred[:, :, 0] = filters.gaussian(im[:, :, 0], 5, preserve_range = True)

print(im[:, :, 0].mean())
print(im_blurred.mean())

truc = plt.imshow(im_blurred)
plt.show()