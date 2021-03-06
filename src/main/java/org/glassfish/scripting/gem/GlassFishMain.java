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
import com.sun.akuma.JavaVMArguments;
import com.sun.enterprise.config.serverbeans.MonitoringService;
import org.glassfish.api.deployment.DeployCommandParameters;
import org.glassfish.api.embedded.EmbeddedDeployer;
import org.glassfish.api.embedded.EmbeddedFileSystem;
import org.glassfish.api.embedded.Port;
import org.glassfish.api.embedded.Server;
import org.glassfish.api.monitoring.ContainerMonitoring;
import org.glassfish.scripting.gem.Options.LogLevel;
import org.jvnet.hk2.config.ConfigSupport;
import org.jvnet.hk2.config.SingleConfigCode;
import org.jvnet.hk2.config.TransactionFailure;

import java.beans.PropertyVetoException;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;
import java.util.logging.ConsoleHandler;
import java.util.logging.FileHandler;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;


/**
 * @author Vivek Pandey
 */
public class GlassFishMain {

    private static void startGlassFishEmbedded(Options options) {

        Logger root = Logger.getLogger("");
        String logLevel = options.log_level.toString();
        root.setLevel(Level.parse(logLevel));

        for (Handler handler : root.getHandlers()) {
            if (handler instanceof ConsoleHandler) {
                root.removeHandler(handler);
            }
        }

        try {
            //create the log file if does not exist
            File logFile = new File(options.log);
            if(!logFile.exists()){
                logFile.getParentFile().mkdirs();
                logFile.createNewFile();
            }

            FileHandler fh = new FileHandler(options.log, true);
            fh.setFormatter(new SimpleFormatter());
            root.addHandler(fh);
        } catch (IOException e) {
            System.err.println("[ERROR] Error setting up log file: " + options.log + ".");
            e.printStackTrace();
        }

        if (options.log_console) {
            GlassFishConsoleHandler gfh = new GlassFishConsoleHandler();
            gfh.setFormatter(new GlassFishLogFormatter());
            root.addHandler(gfh);
        }


        EmbeddedFileSystem.Builder fsBuilder = new EmbeddedFileSystem.Builder();

        EmbeddedFileSystem fs = fsBuilder.instanceRoot(new File(options.domainDir)).build();

        printStatusMessage(options);


        Server.Builder builder = new Server.Builder("jruby");

        builder.embeddedFileSystem(fs).logger(false).logFile(new File(options.log));

        Server server = builder.build();
        server.addContainer(new JRubyContainerBuilder());

        try {
            PortImpl port = new PortImpl(server.getHabitat());
            port.bind(options);
            Runtime.getRuntime().addShutdownHook(new ShutdownThread(server, port));            
            server.start();
            DeployCommandParameters params = new DeployCommandParameters();
            params.contextroot = options.contextRoot;
            params.name = new File(options.appDir).getName();

            Properties props = new Properties();
            props.setProperty("jruby.runtime", String.valueOf(options.runtimes));
            props.setProperty("jruby.runtime.min", String.valueOf(options.runtimes_min));
            props.setProperty("jruby.runtime.max", String.valueOf(options.runtimes_max));
            props.setProperty("jruby.rackEnv", options.environment);
            if(java.lang.System.getProperties().get("glassfish.rackupApp") != null){
                props.setProperty("jruby.applicationType", "config.ru");//this is a hack
            }
                        
            params.property = props;
//            enableMonitoring(server);

            EmbeddedDeployer dep = server.getDeployer();
            dep.deploy(new File(options.appDir), params);
        } catch (Exception e) {
            System.err.println("[ERROR] Error starting GlassFish: "+e.getMessage());
            try {
                System.err.println("Stopping GlassFish!");
                server.stop();
            } catch (Exception e1) {
                System.exit(-1);
            }
        }

    }

    private static class ShutdownThread extends Thread {
        private final Server server;
        private final Port port;
        ShutdownThread(Server server, Port port) {
            this.server = server;
            this.port = port;
        }
        @Override
        public void run() {
            try {
                System.out.println("Stopping GlassFish!");
                this.port.close();
                this.server.stop();
            } catch (Exception e) {
                // log the exception                
                System.exit(-1);
            }
        }
    }


    private static void enableMonitoring(Server server) {
        MonitoringService ms = server.getHabitat().getByType(MonitoringService.class);
        ContainerMonitoring cm = ms.getContainerMonitoring("jruby-container");
        if (cm == null) {
            try {
                ConfigSupport.apply(new SingleConfigCode<MonitoringService>() {
                    public Object run(MonitoringService param) throws PropertyVetoException, TransactionFailure {
                        ContainerMonitoring newItem = param.createChild(ContainerMonitoring.class);
                        newItem.setName("jruby-container");
                        newItem.setLevel("HIGH");
                        param.getContainerMonitoring().add(newItem);
                        return newItem;
                    }
                }, ms);

            } catch (TransactionFailure tf) {
                System.err.println("Error during enabling monitoring" + tf.getMessage());
            }
        } else {
            try {
                ConfigSupport.apply(new SingleConfigCode<ContainerMonitoring>() {
                    public Object run(ContainerMonitoring param) throws PropertyVetoException, TransactionFailure {
                        param.setLevel("HIGH");
                        return null;
                    }
                }, cm);

            } catch (TransactionFailure tf) {
                System.err.println("Error during enabling monitoring: " + tf.getMessage());
            }
        }

    }

    public static void start(final Options options) {
        if (options.daemon) {
            String suffix = "";
            if (options.pid.endsWith("glassfish")) {
                suffix = "-" + LIBC.getpid() + ".pid";
                options.pid = options.pid + suffix;
            }

            final File pid = new File(options.pid);


            if(pid.getParentFile() != null && !pid.getParentFile().exists()){
                System.err.println("PID file directory: "+pid.getParentFile().getAbsolutePath()+" does not exist! Please create this directory to proceed.");
                System.exit(1);
            }
            pid.deleteOnExit();

            Daemon d = new Daemon() {
                // Daemon.writePidFile(String) swallows IOException, so
                // we need to do this
                protected void writePidFile() throws IOException {
                    FileWriter fw = null;
                    try {
                        //there should be better way to do such things
                        fw = new FileWriter(pid);
                        fw.write(String.valueOf(LIBC.getpid()));
                        fw.close();
                    } catch (IOException e) {
                        System.err.println("Error writing pid file: " + pid.getAbsolutePath());
                        logException(e, options);
                        System.exit(1);
                    } finally {
                        if (fw != null) {
                            fw.close();
                        }
                    }
                }
            };
            if (d.isDaemonized()) {
                printDaemonMessage(options);
                try {
                    d.init();
                } catch (Exception e) {
                    System.err.println("Error daemonizing.");
                    logException(e, options);
                    System.exit(1);
                }
            } else {
                // if you are already daemonized, no point in daemonizing yourself again,
                // so do this only when you aren't daemonizing.
                try {
                    String[] array = options.jvm_opts.split(" ");

                    //we first compute the new JVM opts and append the old ones
                    JavaVMArguments newargs = new JavaVMArguments();
                    for (String str : array) {
                        newargs.add(str.trim());
                    }

                    JavaVMArguments jvmargs = JavaVMArguments.current();
                    for (String arg : jvmargs) {
                        //There will be others, for now exluce JRuby -Xmx setting
                        if (!arg.startsWith("-Xmx") && !arg.endsWith("java")) {
                            newargs.add(arg);
                        }
                    }
                    if (options.log_level.compareTo(LogLevel.FINE) > 0) {
                        StringBuffer buff = new StringBuffer();
                        System.out.println("Starting GlassFish with JVM options: ");
                        for (String arg : newargs) {
                            buff.append(arg).append(File.pathSeparator);
                        }
                        System.out.println(buff);
                    }

                    d.daemonize(newargs);
                } catch (IOException e) {
                    System.err.println("Error forking");
                    logException(e, options);
                    System.exit(1);
                }
                System.exit(0);
            }
        }

        startGlassFishEmbedded(options);
    }

    private static void printDaemonMessage(Options options) {
        String logfilename = options.appDir + File.separator + "log" + File.separator + "glassfish-daemon.log";

        File log = new File(logfilename);
        if (!log.exists()) {
            try {
                log.createNewFile();
            } catch (IOException e) {
                System.err.println("Error creating " + logfilename);
                logException(e, options);
                System.exit(1);
            }
        }
        FileWriter fw = null;
        try {
            fw = new FileWriter(log, true);
            String msg1 = "Starting GlassFish as daemon at: " + options.address + ":" + options.port + " in " + options.environment + " environment...";
            String msg2 = "Writing log messages to: " + options.log + ".";
            String msg3 = "To stop, kill -s SIGINT " + LIBC.getpid();

            DateFormat dateFormat = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss a Z");
            Date date = new Date();
            fw.append(dateFormat.format(date) + "\n");

            fw.append(msg1 + "\n");

            fw.append(msg2 + "\n");
            fw.append("Writing pid file to: " + options.pid + "\n");
            fw.append(msg3 + "\n\n");

            System.out.println(msg1);
            System.out.println("Server startup messages are written in: " + log.getAbsolutePath());
            System.out.println(msg3);
        } catch (FileNotFoundException e) {
            logException(e, options);
        } catch (IOException e) {
            logException(e, options);
        } finally {
            if (fw != null) {
                try {
                    fw.close();
                } catch (IOException e) {
                    logException(e, options);
                }
            }
        }

    }

    private static void printStatusMessage(Options options) {
        if (!options.daemon) {
            System.out.println("Starting GlassFish server at: " + options.address + ":" + options.port + " in " + options.environment + " environment...");
            System.out.println("Writing log messages to: " + options.log + ".");
            System.out.println("Press Ctrl+C to stop.\n");
        }
    }

    private static void logException(Exception e, Options opts) {
        //if the log level is more than INFO, then
        if (opts.log_level.compareTo(LogLevel.INFO) > 0) {
            e.printStackTrace();
        } else {
            System.err.println(e.getMessage());
        }
    }

}
