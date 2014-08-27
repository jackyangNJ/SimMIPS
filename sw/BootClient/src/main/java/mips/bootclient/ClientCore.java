package mips.bootclient;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.util.logging.Level;
import jssc.SerialPort;
import jssc.SerialPortEvent;
import jssc.SerialPortEventListener;
import jssc.SerialPortException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author jack
 */
public class ClientCore implements SerialPortEventListener {

    static final Logger logger = LogManager.getLogger(ClientCore.class.getName());

    SerialPort serialPort;
    public static final int MSG_ELF_TYPE = 10;
    public static final int MSG_BIN_TYPE = 11;
    public static final int MSG_BOOT_TYPE = 12;
    ByteBuffer lineBuf = ByteBuffer.allocate(10000);

    public boolean openSeriaPort(String portName, int portBaudRate) {
        serialPort = new SerialPort(portName);
        try {
            serialPort.openPort();
            //Set params. Also you can set params by this string: serialPort.setParams(9600, 8, 1, 0);
            serialPort.setParams(portBaudRate,
                    SerialPort.DATABITS_8,
                    SerialPort.STOPBITS_1,
                    SerialPort.PARITY_NONE);

            //Set mask
            int mask = SerialPort.MASK_RXCHAR;//Prepare mask
            serialPort.setEventsMask(mask);

            //Add SerialPortEventListener
            serialPort.addEventListener(this);

        }
        catch (SerialPortException ex) {
            logger.error(ex);
            return false;
        }
        return true;
    }

    /**
     * send ELF file to cpu, |0 |1 2 3 4|5 6 7 8 |... |type |length |addr to
     * place file|file contents
     *
     * @param filePath
     * @param addr
     * @return
     */
    public boolean sendBIN(String filePath, long addr) {
        File file = new File(filePath);
        InputStream in;
        byte[] fileContents;
        int len;
        try {
            in = new FileInputStream(file);
            fileContents = new byte[in.available()];
            len = in.read(fileContents, 0, in.available());
            logger.info("file length = " + len);
        }
        catch (FileNotFoundException ex) {
            logger.error(ex);
            return false;
        }
        catch (IOException ex) {
            logger.error(ex);
            return false;
        }

        if (len != 0 && isSerialOpened()) {
            try {
                serialPort.writeInt(MSG_BIN_TYPE); // one byte
                serialWriteLong(len);
                serialWriteLong(addr);
//                serialPort.writeBytes(fileContents);
                for (byte b : fileContents) {
                    serialPort.writeByte(b);
                    try {
                        Thread.sleep(1);
                    } catch (InterruptedException ex) {
                        java.util.logging.Logger.getLogger(ClientCore.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }
            }
            catch (SerialPortException ex) {
                logger.error(ex);
            }
        }
        return true;

    }

    /**
     * in little endian,send a int in 4 byte
     *
     * @param value
     */
    private void serialWriteLong(long value) throws SerialPortException {
        if (isSerialOpened()) {
            serialPort.writeInt((int) (value & 0xFF));
            serialPort.writeInt((int) ((value >> 8) & 0xFF));

            serialPort.writeInt((int) ((value >> 16) & 0xFF0000));
            serialPort.writeInt((int) ((value >> 24) & 0xFF));

//            logger.info((int) (value & 0xFF));
//            logger.info((int) ((value >> 8) & 0xFF));
//            logger.info((int) ((value >> 16) & 0xFF));
//            logger.info((int) ((value >> 24) & 0xFF));
        }
    }

    /**
     *
     * @param addr CPU PC will jump to addr
     * @return
     */
    public boolean sendBootAddr(long addr) {

        if (isSerialOpened()) {
            try {
                serialPort.writeInt(MSG_BOOT_TYPE);
                serialWriteLong(addr);
            }
            catch (SerialPortException ex) {
                logger.error(ex);
                return false;
            }
        } else {
            logger.info("serial is not open.");
            return false;
        }
        return true;
    }

    public boolean isSerialOpened() {
        if (serialPort != null) {
            return serialPort.isOpened();
        }
        return false;
    }

    public boolean closeSerial() {
        if (isSerialOpened()) {
            try {
                serialPort.closePort();
            }
            catch (SerialPortException ex) {
                logger.error(ex);
                return false;
            }
        }
        return true;
    }

    /**
     *
     * @param event
     */
    @Override
    public void serialEvent(SerialPortEvent event) {
        if (event.isRXCHAR()) {//If data is available
            //Read data, if 10 bytes available 
            try {
                byte buffer[];
                while (true) {
                    buffer = serialPort.readBytes(1);
                    if (buffer.length == 0) {
                        break;
                    }
                    if (buffer[0] == '\n') {
                        logger.info(new String(lineBuf.array(),0,lineBuf.position()));
                        lineBuf.clear();
                    } else {
                        lineBuf.put(buffer);
                    }
                }
            }
            catch (SerialPortException ex) {
                logger.error(ex);
            }
        }
    }

}
