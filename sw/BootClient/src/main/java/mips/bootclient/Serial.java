package mips.bootclient;

import jssc.SerialPort;
import jssc.SerialPortException;
import jssc.SerialPortList;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author jack
 */
public class Serial extends SerialPort{

    static final Logger logger = LogManager.getLogger(Serial.class.getName());

    SerialPort serialPort;

    public Serial(String portName) {
        super(portName);
    }

    String[] listPorts() {
        return SerialPortList.getPortNames();
    }

    public boolean openSerialPort(String portName, int portBaudRate) {
        serialPort = new SerialPort(portName);
        try {
            serialPort.openPort();
            //Set params. Also you can set params by this string: serialPort.setParams(9600, 8, 1, 0);
            serialPort.setParams(portBaudRate,
                    SerialPort.DATABITS_8,
                    SerialPort.STOPBITS_1,
                    SerialPort.PARITY_NONE);
        } catch (SerialPortException ex) {
            logger.error(ex);
            return false;
        }
        return true;
    }

    public static void main(String[] args) {

    }
}
