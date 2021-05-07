import pyautogui, imutils
from tkinter import *
import cv2
import time, os
import numpy as np
import pytesseract
from PIL import Image


cv2.namedWindow('Camera',cv2.WINDOW_NORMAL)
#cv2.resizeWindow('Camera', 960, 540)
print(os.path.dirname(os.path.abspath(__file__)) + '/Tesseract/tesseract.exe')
pytesseract.pytesseract.tesseract_cmd = os.path.dirname(os.path.abspath(__file__)) + '/Tesseract/tesseract.exe'

def rotate_image(image, angle):
  image_center = tuple(np.array(image.shape[1::-1]) / 2)
  rot_mat = cv2.getRotationMatrix2D(image_center, angle, 1.0)
  result = cv2.warpAffine(image, rot_mat, image.shape[1::-1], flags=cv2.INTER_LINEAR)
  return result

def shear_image(image, angle):
    rows, cols, dim = image.shape
    M = np.float32([[1, angle/360, 0],[0, 1, 0], [0, 0, 1]])
    return cv2.warpPerspective(image,M,(int(cols*1.5),int(rows*1.5)))

while(True):
    #time.sleep(1)
    image = pyautogui.screenshot()
    image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2GRAY)
    image = image[890:960, 250:370]
    image = rotate_image(image, -3)
    image = 255 - image
    
    image = cv2.resize(image, (int(len(image[0])*4), int(len(image)*4)))
    m = Image.Image.getextrema(Image.fromarray(image))[0]
    #image = cv2.convertScaleAbs(image, alpha=1.3, beta=0)
    image = cv2.inRange(image, max(m-30,0), min(m + 40,255))
    image = 255 - image
    #image = 255 - image
    kernel = np.ones((2,2),np.uint8)
    image = cv2.erode(image,kernel,iterations = 1)
    
    cv2.imshow('Camera',image)
    pyText = pytesseract.image_to_string(image, config='digits --psm 7 -c page_separator=""').splitlines()
    if(len(pyText) > 0):
      print(pyText[0])

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cv2.destroyAllWindows()