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
    public int log_level;
    public String domainDir;
	public String jvm_opts;

    @Override
    public String toString() {
        return "runtimes: " + String.valueOf(runtimes)+" "+
                "runtimes-min: " + String.valueOf(runtimes_min)+" "+
                "runtimes-max: " + String.valueOf(runtimes_max)+" "+
                "contextroot: " + contextRoot+" "+
                "environment: " + environment+" "+
                "appDir: " + appDir +" "+
                "address: " + address +" "+                
                "port: "+String.valueOf(port)+" "+
                "Deamon: "+String.valueOf(daemon)+" "+
                "pid: " + pid + " "+
                "log: " + log + " " +
                "log_console: " + log_console + " "+
                "log-level: " + log_level +
				"jvm_opts: "+ jvm_opts +
                "domain director: "+domainDir;
    }
}
