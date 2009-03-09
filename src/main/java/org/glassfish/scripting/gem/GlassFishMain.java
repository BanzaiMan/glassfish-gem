/*
 *
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
 *
 * Copyright 2008 Sun Microsystems, Inc. All rights reserved.
 *
 * The contents of this file are subject to the terms of either the GNU
 * General Public License Version 2 only ("GPL") or the Common Development
 * and Distribution License("CDDL") (collectively, the "License").  You
 * may not use this file except in compliance with the License. You can obtain
 * a copy of the License at https://glassfish.dev.java.net/public/CDDL+GPL.html
 * or glassfish/bootstrap/legal/LICENSE.txt.  See the License for the specific
 * language governing permissions and limitations under the License.
 *
 * When distributing the software, include this License Header Notice in each
 * file and include the License file at glassfish/bootstrap/legal/LICENSE.txt.
 * Sun designates this particular file as subject to the "Classpath" exception
 * as provided by Sun in the GPL Version 2 section of the License file that
 * accompanied this code.  If applicable, add the following below the License
 * Header, with the fields enclosed by brackets [] replaced by your own
 * identifying information: "Portions Copyrighted [year]
 * [name of copyright owner]"
 *
 * Contributor(s):
 *
 * If you wish your version of this file to be governed by only the CDDL or
 * only the GPL Version 2, indicate your decision by adding "[Contributor]
 * elects to include this software in this distribution under the [CDDL or GPL
 * Version 2] license."  If you don't indicate a single choice of license, a
 * recipient has the option to distribute your version of this file under
 * either the CDDL, the GPL Version 2 or to extend the choice of license to
 * its licensees as provided above.  However, if you add GPL Version 2 code
 * and therefore, elected the GPL Version 2 license, then the option applies
 * only if the new code is made subject to such option by the copyright
 * holder.
 */

package org.glassfish.scripting.gem;

import static com.sun.akuma.CLibrary.LIBC;
import com.sun.akuma.Daemon;
import com.sun.enterprise.glassfish.bootstrap.ASMain;
import org.glassfish.api.admin.ParameterNames;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.LogManager;
import java.io.*;


/**
 * @author Vivek Pandey
 */
public class GlassFishMain {
    private static void startGlassFish(Options options) {
        System.setProperty("jruby.runtime", String.valueOf(options.runtimes));
        System.setProperty("jruby.runtime.min", String.valueOf(options.runtimes_min));
        System.setProperty("jruby.runtime.max", String.valueOf(options.runtimes_max));
        System.setProperty("rails.env", options.environment);
        System.setProperty("jruby.gem.port", String.valueOf(options.port));
        System.setProperty("GlassFish_Platform", "Static");
        System.setProperty("glassfish.static.cache.dir", options.domainDir);
        System.setProperty("jruby.log.location", options.log);

        String logLevel = getLogLevel(options.log_level);

        Properties props = new Properties();
        try {
            String logFile = options.domainDir+ File.separator+"config"+File.separator+"logging.properties";
            InputStream fis = new FileInputStream(logFile);
            props.load(fis);
            fis.close();
            for(Object key : props.keySet()){

                if(((String)key).endsWith(".level") && (props.get(key) == null || !props.get(key).equals(logLevel))){
                    props.put(key, logLevel);
                }
            }
            OutputStream fos = new FileOutputStream(logFile);
            props.store(fos, "Updated Glassfish gem level to: "+logLevel);
            fos.close();
        } catch (FileNotFoundException e) {
            //skip
        } catch (IOException e) {
            //skip
        }

        //We disable al messages shown by anonymous loggers. This will filter lot of junk!
        LogManager.getLogManager().getLogger("").setLevel(Level.OFF);
        printStatusMessage(options);
        ASMain.main(new String[]{options.appDir, "--"+ParameterNames.CONTEXT_ROOT, options.contextRoot, "--domaindir", options.domainDir});
    }

    public static void start(final Options options) {
        Daemon d = new Daemon(){
            @Override
            protected void writePidFile() throws IOException {
                try {
                    //there should be better way to do such things
                    String suffix="";
                    if(options.pid.endsWith("glassfish"))
                        suffix = "-"+LIBC.getpid()+".pid";
                    
                    File pid = new File(options.pid+suffix);
                    pid.deleteOnExit();
                    FileWriter fw = new FileWriter(pid);
                    fw.write(String.valueOf(LIBC.getpid()));
                    fw.close();
                } catch (IOException e) {
                    // if failed to write, keep going because maybe we are run from non-root
                }
            }
        };
        if (d.isDaemonized()) {
            printStatusMessage(options);
            try {
                d.init();
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            // if you are already daemonized, no point in daemonizing yourself again,
            // so do this only when you aren't daemonizing.
            if (options.daemon) {
                try {
                    //TODO: patch JVM args to suit GlassFish
                    d.daemonize();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                System.exit(0);
            }
        }

        startGlassFish(options);
    }

    private static void printStatusMessage(Options options) {
        String host;
        try {
            host = InetAddress.getLocalHost().getHostAddress();
        } catch (UnknownHostException e) {
            host = "0.0.0.0";
        }

        System.out.println("Starting GlassFish server at: " + host + ":" + options.port);

        //Show this message only if logging is turned ON
        if (options.log_level > 0)
            System.out.println("Logging messages to: " + options.log + ", using log Level: " + getLogLevel(options.log_level));
        System.out.println("Process Id: " + LIBC.getpid());
    }

    private static String getLogLevel(int level){
        String logLevel = "INFO";
        switch(level){
            case 0:
                logLevel = "OFF";
                break;
            case 1:
                logLevel = "INFO";
                break;
            case 2:
                logLevel = "WARNING";
                break;
            case 3:
                logLevel = "SEVERE";
                break;
            case 4:
                logLevel = "FINE";
                break;
            case 5:
                logLevel = "FINER";
                break;
            case 6:
                logLevel = "FINEST";
                break;
            case 7:
                logLevel = "ALL";
                break;
            default:
                System.err.println("Invalid log level: "+level+". Default log level 1:INFO will be used.");
        }
        return logLevel;
    }
}
