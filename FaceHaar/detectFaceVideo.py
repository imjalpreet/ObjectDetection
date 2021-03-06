import numpy as np
import cv2
from matplotlib import pyplot as plt
import os
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
eye_cascade = cv2.CascadeClassifier('haarcascade_eye.xml')

for a,b,c in os.walk('../Code/object-detector/Frames/'):
    i = 0
    for image in c:
        img = cv2.imread('../Code/object-detector/Frames/'+image)
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.2, 5)
        if len(faces) == 0:
            print "No Faces Found"
        for (x,y,w,h) in faces:
            cv2.rectangle(img,(x,y),(x+w,y+h),(255,0,0),2)
            roi_gray = gray[y:y+h, x:x+w]
            roi_color = img[y:y+h, x:x+w]
            eyes = eye_cascade.detectMultiScale(roi_gray)
            for (ex,ey,ew,eh) in eyes:
	            cv2.rectangle(roi_color,(ex,ey),(ex+ew,ey+eh),(0,255,0),2)

        cv2.imwrite("Frames/" + str(i) + ".pgm", img)
        i += 1
#cv2.waitKey(0)
#cv2.destroyAllWindows()
