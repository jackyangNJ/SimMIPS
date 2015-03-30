package mips.bootclient;

import de.tototec.cmdoption.CmdOption;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author yj
 */
class Config {

    static final Logger logger = LogManager.getLogger(Config.class.getName());

    @CmdOption(names = {"--help", "-h"}, description = "Show this help.", isHelp = true)
    public boolean help;

    @CmdOption(names = {"-addr"}, args = {"addr"}, maxCount = 1, minCount = 1, description = "Point to target addr(needed).")
    public final String targetAddr = new String();

    @CmdOption(names = {"-entry", "-e"}, args = {"addr"}, maxCount = 1, minCount = 1, description = "Point to entry addr(needed).")
    public final String entryAddr = new String();

    @CmdOption(names = {"-file", "-f"}, args = {"filePath"}, maxCount = 1, description = "Specify the file path to transfer file via seiral(Optional).")
    public final String filePath = new String();

    @CmdOption(names = {"-serial", "-s"}, args = {"portName"}, minCount = -1, maxCount = 2, description = "Specify the serial port(Default:).")
    public final String serialPortName = "COM4";

    @CmdOption(names = {"-rate", "-r"}, args = {"portBaudRate"}, minCount = -1, maxCount = 2, description = "Specify the serial baud rate(Default:).")
    public final String serialPortBaudRate = "115200";

    @CmdOption(args = {"extraParams"}, description = "additional parameters.", maxCount = -1)
    public final List<String> extraParams = new ArrayList<>();

}
