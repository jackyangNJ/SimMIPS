package mips.bootclient;

import java.io.File;
import jssc.SerialPort;

/**
 *
 * @author jack
 */
public class ClientCore {
    SerialPort serialPort;
    public boolean openSeriaPort(String portName,int portBaudRate){
        return true;
    }
    
    public boolean sendELF(File file){
        return true;
    }
    public boolean sendBootAddr(int addr){
        
        return true;
    }
}
