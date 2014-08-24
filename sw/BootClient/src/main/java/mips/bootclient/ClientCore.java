package mips.bootclient;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import jssc.SerialPort;
import jssc.SerialPortException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author jack
 */
public class ClientCore {

    static final Logger logger = LogManager.getLogger(ClientCore.class.getName());

    SerialPort serialPort;
    public static final int MSG_ELF_TYPE = 0;
    public static final int MSG_BOOT_TYPE = 1;

    public boolean openSeriaPort(String portName, int portBaudRate) {
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
    public boolean sendELF(String filePath, int addr) {
        File file = new File(filePath);
        InputStream in = null;
        byte[] fileContents = null;
        try {
            in = new FileInputStream(file);
            in.read(fileContents,0,in.available());
        } catch (FileNotFoundException ex) {
            logger.error(ex);
            return false;
        } catch (IOException ex) {
            logger.error(ex);
            return false;
        }

        if (fileContents.length != 0 && isSerialOpened()) {
            try {
                serialPort.writeInt(MSG_ELF_TYPE);
                serialWriteLong(fileContents.length);
                serialWriteLong(addr);
                serialPort.writeBytes(fileContents);
            } catch (SerialPortException ex) {
                logger.error(ex);
            }
        }
        return true;
    }

    /**
     * in little endian
     *
     * @param value
     */
    private void serialWriteLong(int value) throws SerialPortException {
        if (isSerialOpened()) {
            serialPort.writeInt(value & 0xFF);
            serialPort.writeInt(value & 0xFF00);
            serialPort.writeInt(value & 0xFF0000);
            serialPort.writeInt(value & 0xFF000000);
        }
    }

    /**
     *
     * @param addr CPU PC will jump to addr
     * @return
     */
    public boolean sendBootAddr(int addr) {

        if (isSerialOpened()) {
            try {
                serialPort.writeInt(MSG_BOOT_TYPE);
                serialWriteLong(addr);
            } catch (SerialPortException ex) {
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
            } catch (SerialPortException ex) {
                logger.error(ex);
                return false;
            }
        }
        return true;
    }
}
