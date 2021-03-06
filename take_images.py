import ueye
import time
import Image
import numpy as np
import fringe_gen as fg

    
def numCameras():
    ncam=ueye.GetNumberOfCameras()    
    return ncam
    
def setupCamera(): #### uEye camera init
    global cam
    cam = ueye.Cam()
    cMode = cam.SetColorMode(6) # greyscale 8 bit = 6
    gMode = cam.SetGainBoost(3) # turn of analogue gain = 3 (on = 2)
    cam.SetHardwareGain(1,1,1,1) # only change first for master gain 0-100
    rv=cam.SetBinning(0)
    rv=cam.SetSubSampling(0)
    pnMin, pnMax=cam.GetPixelClockRange() # set pixel clock to minimum
    pClock=cam.SetPixelClock(pnMin)
    fMin,fMax,intervall= cam.GetFrameTimeRange() # set framerate to min
    fps = cam.SetFrameRate(fMin)
    eMin,eMax,interval=cam.GetExposureRange() # set exposure to max
    exposure = cam.SetExposureTime(eMax)
    

def grabResponse(screen,gain = 100):
    for i in range(0,275,25):
        fg.fringeGen(screen,i, calib = True)
        time.sleep(1)
        im = grabStack(screen,5,gain)
        saveImage('images/new/c'+str(i)+'.png',im)
        time.sleep(1)
        

def grabAll(screen,spacing,stacksize = 9,gain = 100):
    fg.fringeGen(screen,spacing, calib = False, vert = False, phase = 0)
    time.sleep(1)
    im = grabStack(screen,stacksize,gain)
    saveImage('images/new/'+str(spacing)+'h00.png',im)
    
    fg.fringeGen(screen,spacing, calib = False, vert = False, phase = 90)
    time.sleep(1)
    im = grabStack(screen,stacksize,gain)
    saveImage('images/new/'+str(spacing)+'h90.png',im)
    
    fg.fringeGen(screen,spacing, calib = False, vert = False, phase = 180)
    time.sleep(1)
    im = grabStack(screen,stacksize,gain)
    saveImage('images/new/'+str(spacing)+'h180.png',im)
    
    fg.fringeGen(screen,spacing, calib = False, vert = False, phase = 270)
    time.sleep(1)
    im = grabStack(screen,stacksize,gain)
    saveImage('images/new/'+str(spacing)+'h270.png',im)
    
    fg.fringeGen(screen,spacing, calib = False, vert = True, phase = 0)
    time.sleep(1)
    im = grabStack(screen,stacksize,gain)
    saveImage('images/new/'+str(spacing)+'v00.png',im)
    
    fg.fringeGen(screen,spacing, calib = False, vert = True, phase = 90)
    time.sleep(1)
    im = grabStack(screen,stacksize,gain)
    saveImage('images/new/'+str(spacing)+'v90.png',im)
    
    fg.fringeGen(screen,spacing, calib = False, vert = True, phase = 180)
    time.sleep(1)
    im = grabStack(screen,stacksize,gain)
    saveImage('images/new/'+str(spacing)+'v180.png',im)
    
    fg.fringeGen(screen,spacing, calib = False, vert = True, phase = 270)
    time.sleep(1)
    im = grabStack(screen,stacksize,gain)
    saveImage('images/new/'+str(spacing)+'v270.png',im)
 
def grabStack(screen,stacksize,gain):
    cam.SetHardwareGain(gain,1,1,1) 
    stack = np.zeros((1024,1280,stacksize))
    for i in range(stacksize):
        stack[...,i] = cam.GrabImage()
        time.sleep(0.5)    
    im = np.median(stack,axis=2)
    return im


def saveImage(filename,data):
    tmp = (data).astype(np.uint8)
    im = Image.fromarray(tmp)
    im.save(filename)
