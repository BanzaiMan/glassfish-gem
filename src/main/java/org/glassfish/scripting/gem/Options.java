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

import org.jruby.runtime.builtin.IRubyObject;

/**
 * @author Vivek Pandey
 */
public class Options{
    public int runtimes;
    public int runtimes_min;
    public int runtimes_max;
    public String contextRoot;
    public String environment;
    public String appDir;
    public int port;
    public String address;
    public boolean daemon;
    public String pid;
    public String log;
    public boolean log_console;
    public LogLevel log_level;
    public String domainDir;
    public String jvm_opts;
    public IRubyObject app;
    public GrizzlyConfig grizzlyConfig = new GrizzlyConfig();

    public enum LogLevel {
        OFF, SEVERE, WARNING, INFO, FINE, FINER, FINEST, ALL
    }

    @Override
    public String toString() {
        StringBuffer sb = new StringBuffer("GlassFish gem configurtion: ");
        return sb.append("\n\t").append("runtimes: ").append(runtimes)
                .append("\n\t").append("runtimes-min: ").append(runtimes_min)
                .append("\n\t").append("runtimes-maz: ").append(runtimes_max)
                .append("\n\t").append("contextroot: ").append(contextRoot)
                .append("\n\t").append("environment: ").append(environment)
                .append("\n\t").append("appRoot: ").append(appDir)
                .append("\n\t").append("address: ").append(address)
                .append("\n\t").append("port: ").append(port)
                .append("\n\t").append("daemon: ").append(daemon)
                .append("\n\t").append("pid: ").append(pid)
                .append("\n\t").append("log: ").append(log)
                .append("\n\t").append("log to console: ").append(log_console)
                .append("\n\t").append("JVM options: ").append(jvm_opts)
                .append("\n\t").append("domain dir: ").append(domainDir)
                .append("\n\t").append(grizzlyConfig).toString();

    }

    public class GrizzlyConfig{
        public boolean chunkingEnabled=true;
        public int requestTimeout = 30;
        public int sendBufferSize = 8192;
        public int maxKeepaliveConnections = 256;
        public int keepaliveTimeout = 30;
        public ThreadPool threadPool = new ThreadPool();

        @Override
        public String toString() {
            StringBuffer sb = new StringBuffer("Grizzly Configuration:");
            return sb.append("\n\t").append("chunking_enabled: ").append(chunkingEnabled)
                    .append("\n\t").append("request_timeout: ").append(requestTimeout)
                    .append("\n\t").append("sendBufferSize: ").append(sendBufferSize)
                    .append("\n\t").append("maxKeepaliveConnections: ").append(maxKeepaliveConnections)
                    .append("\n\t").append("keepaliveTimeout: ").append(keepaliveTimeout)
                    .append("\n\t").append(threadPool).toString();
        }

        public class ThreadPool{
            public int idleThreadTimeoutSeconds = 900;
            public int maxQueueSize = 4096;
            public int maxThreadPoolSize = 5;
            public int minThreadPoolSize = 2;

            @Override
            public String toString() {
                StringBuffer sb = new StringBuffer("Grizzly Thread Pool Config:");
                return sb.append("\n\t").append("idle_thread_timeout_seconds: ").append(idleThreadTimeoutSeconds)
                        .append("\n\t").append("max_queue_size: ").append(maxQueueSize)
                        .append("\n\t").append("max_thread_pool_size: ").append(maxThreadPoolSize)
                        .append("\n\t").append("min_thread_pool_size: ").append(minThreadPoolSize).toString();
            }
        }
    }    
}
