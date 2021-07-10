import pyautogui
import time

time.sleep(3)
start = time.time()

for x in range(1, 51):
    shot = pyautogui.screenshot()
    shot.save(str(x) + ".png")
print(time.time() - start)