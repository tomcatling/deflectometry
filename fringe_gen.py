import pygame
import math
import numpy as np
from pygame.locals import *

 
# constants 
h = 1600
w = 900 
    
# initialise pygame display to screen size
def setupScreen():
    pygame.init()
    size=(w,h)
    return pygame.display.set_mode(size,pygame.RESIZABLE)

# place fringes on the screen
def fringeGen(screen, desired_period, calib = False, vert=True, phase=0):

    rgb_img = np.zeros((w,h,3))

    # if we want a calibration screen
    if calib:
        img = np.ones((w,h))*(desired_period%255)

    else:
    
        pixel_size = 440./h # pixel size in mm, calculated by width of screen (~440mm)

        p = desired_period / pixel_size
        
        if vert:

            x = range(w)
            z = []

            for i in x:
                value = (math.sin( x[i]*2.*math.pi/p + phase)+1)*127.
                z.append(value)

            img = np.zeros((w,h))

            for i in range(h):
                img[:,i] = z
            
        else:

            y = range(h)
            z = []

            for i in y:
                value = (math.sin( y[i]*2.*math.pi/p + phase)+1)*127.
                z.append(value)

            img = np.zeros((w,h))

            for i in range(w):
                img[i,:] = z
           

    rgb_img[...,0] = img
    rgb_img[...,1] = img
    rgb_img[...,2] = img

    I=pygame.surfarray.make_surface(rgb_img)

    screen.blit(I,(0,0))
    pygame.display.update() # update the display




