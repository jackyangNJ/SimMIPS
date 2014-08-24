package mips.bootclient;

import de.tototec.cmdoption.CmdOption;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.Map;

/**
 *
 * @author yj
 */
class Config {

    @CmdOption(names = {"--help", "-h"}, description = "Show this help.", isHelp = true)
    public boolean help;

    @CmdOption(names = {"--verbose", "-v"}, description = "Be more verbose.")
    public boolean verbose;

    @CmdOption(names = {"--options", "-o"}, args = {"name", "value"}, maxCount = -1, description = "Additional options when processing names.")
    public final Map<String, String> options = new LinkedHashMap<String, String>();

    @CmdOption(args = {"file"}, description = "Names to process.", minCount = 1, maxCount = -1)
    public final List<String> names = new LinkedList<String>();

}
