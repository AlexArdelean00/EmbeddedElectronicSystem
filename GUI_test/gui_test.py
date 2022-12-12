from tkinter import *  # Python 3
from PIL import ImageTk, Image
from tkinter import filedialog
from tkinter import ttk
import os
import time
import serial 
import numpy as np
from threading import Thread

class App:
    def __init__(self):
        # root window
        self.root = Tk()
        self.root.geometry("1200x500")
        self.root.minsize(1200, 500)
        self.root.title('Image Point Operation')

        # configure the grid
        self.root.columnconfigure(0, weight=1)
        self.root.columnconfigure(1, weight=1)
        self.root.columnconfigure(2, weight=1)

        # immagine originale
        self.left_canvas = Canvas(self.root, width=500, height=500)
        self.left_canvas.grid(column=0, row=0, sticky=NS, rowspan=5)
        self.left_canvas.create_image(0, 0, anchor=NW, image=None)

        # bottoni
        self.selected_COM = StringVar()
        self.com_cb = ttk.Combobox(self.root, textvariable=self.selected_COM)
        self.com_cb['values'] = (
            'COM1',
            'COM2',
            'COM3',
            'COM4',
            'COM5',
            'COM6',
            'COM7',
            'COM8',
            'COM9',
            'COM10',
        )
        self.com_cb.bind('<<ComboboxSelected>>', self.com_selezionata)    
        self.com_cb.current(3)
        self.com_selezionata()
        self.com_cb.grid(column=1, row=0)

        self.carica_img_button = Button(self.root, text="Carica Immagine", command=self.apri_immagine)
        self.carica_img_button.grid(column=1, row=1)

        self.invia_dati_button = Button(self.root, text="Invia Dati", command=self.invia_dati)
        self.invia_dati_button.grid(column=1, row=2)

        self.esci_button = Button(self.root, text="Esci", command=self.root.destroy)
        self.esci_button.grid(column=1, row=3)

        # immagine elaborata
        self.right_canvas = Canvas(self.root, width=500, height=500)
        self.right_canvas.grid(column=2, row=0, sticky=NS, rowspan=5)
        self.right_canvas.create_image(0, 0, anchor=NW, image=None)

        self.root.mainloop()

    def apri_immagine(self):
        filename = filedialog.askopenfilename(title='open')
        self.img = Image.open(filename)
        self.w, self.h = self.img.size
        self.array = np.asarray(self.img, np.uint8)
        self.data = self.array.tobytes()
        print(f"Aperta immagine: {self.img}")
        self.visualizza_immagine(self.img, self.left_canvas)
        
    def visualizza_immagine(self, img, canvas):    
        w, h = img.size
        if w > h:
            scaleFactor = 500/self.w
        else:
            scaleFactor = 500/self.h

        temp = img.copy()
        width, height = temp.size
        temp = temp.resize((int(width*scaleFactor), int(height*scaleFactor)), Image.ANTIALIAS)

        vImg = ImageTk.PhotoImage(temp)

        canvas.delete("all")
        canvas.create_image(0, 0, anchor=NW, image=vImg)
        self.root.mainloop()
    
    def com_selezionata(self):
        print (self.com_cb.get())
        try:
            self.ser = serial.Serial \
            (
                port=self.com_cb.get(),
                baudrate=4000000,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                bytesize=serial.EIGHTBITS,
                timeout = 20
            )
            print(self.ser)
        except:
            print(f"Nessun dispositivo rilevato su {self.com_cb.get()}")

    def invia_dati(self):
        tx = Thread(target=self.TxThread)
        rx = Thread(target=self.RxThread)
        tx.start()
        rx.start()
        tx.join()
        rx.join()
        self.visualizza_immagine(self.elab_img, self.right_canvas)

    def TxThread(self):
        print("Transmission started.")
        d = [self.data[i:i+10000] for i in range(0, len(self.data), 10000)]
        for t in d:
            self.ser.write(t)
            time.sleep(0.0000001)
        #time.sleep(1)
        print("Transmission finished.")

    def RxThread(self):
        print("Reception started.")
        r_data = self.ser.read(len(self.data))
        print(f"received: {len(r_data)} bytes")
        print("Reception finished.")
        print(f"Received data == data: {self.data == r_data}")

        ba = bytearray(r_data)

        int_values = [x for x in ba]

        int_values = np.asarray(int_values)
        int_values = int_values.reshape(self.h,self.w,3)

        img = Image.fromarray(np.uint8(int_values))
        self.elab_img = img

if __name__ == "__main__":
    app = App()