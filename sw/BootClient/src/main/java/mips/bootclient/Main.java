package mips.bootclient;

import de.tototec.cmdoption.CmdlineParser;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author yj
 */
public class Main {

    static final Logger logger = LogManager.getLogger(Main.class.getName());
    Config config = new Config();
    CmdlineParser cp;
    ClientCore clientCore = new ClientCore();

    public Main(String[] args) {
        CmdlineParser cp = new CmdlineParser(config);
        cp.parse(args);
    }

    public void run() {

        //display usage
        if (config.help || config.targetAddr.equals("")) {
            cp.usage();
            System.exit(0);
        }

        logger.info("Target Addr = " + config.targetAddr);
        logger.info("Using serial " + config.serialPortName + " at rate " + config.serialPortBaudRate);

        //open serial port
        clientCore.openSeriaPort(config.serialPortName, Integer.decode(config.serialPortBaudRate));

//        return;
        //send command 
        if (!config.filePath.equals("")) {
            //send bin
            boolean rtn = clientCore.sendBIN(config.filePath, Long.decode(config.targetAddr));
            if(!rtn)
                return;
        }

        //send boot command
        clientCore.sendBootAddr(Long.decode(config.entryAddr));

    }

    public static void main(String[] args) {
        /* Set the Nimbus look and feel */
//        //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
//        /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
//         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
//         */
//        try {
//            for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
//                if ("Nimbus".equals(info.getName())) {
//                    javax.swing.UIManager.setLookAndFeel(info.getClassName());
//                    break;
//                }
//            }
//        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException | javax.swing.UnsupportedLookAndFeelException ex) {
//            java.util.logging.Logger.getLogger(MainFrame.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
//        }
//        //</editor-fold>
//
//        /* Create and display the form */
//        java.awt.EventQueue.invokeLater(new Runnable() {
//            public void run() {
//                new MainFrame().setVisible(true);
//            }
//        });

        Main main = new Main(args);
        main.run();
//        System.exit(0);
    }
}
