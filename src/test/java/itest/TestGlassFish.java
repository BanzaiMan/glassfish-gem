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
package itest;

import junit.framework.TestCase;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.net.URLClassLoader;
import java.net.MalformedURLException;
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;

import org.junit.Test;

/**
 * @author Vivek Pandey
 */

public class TestGlassFish{

    private final ClassLoader cl;

    public TestGlassFish() throws MalformedURLException {
        String gfloc = System.getProperty("glassfish.home") + "/modules/";
        System.out.println("GF home: "+gfloc);
        System.out.println("Test home: "+System.getProperty("test.home"));        
        cl = new URLClassLoader(new URL[]{absolutize(gfloc+"glassfish.jar"), absolutize(gfloc+"glassfish-gem.jar")},ClassLoader.getSystemClassLoader().getParent());
    }

    @Test
    public void testDefaultStartup() throws IOException, ClassNotFoundException, NoSuchMethodException, InvocationTargetException, IllegalAccessException, InstantiationException, NoSuchFieldException, InterruptedException {
        Class optsc = cl.loadClass("org.glassfish.scripting.gem.Options");
        Object opts = optsc.getConstructor().newInstance();
        optsc.getField("contextRoot").set(opts, "\\");
        optsc.getField("runtimes").setInt(opts, 1);
        optsc.getField("runtimes_min").setInt(opts, 1);
        optsc.getField("runtimes_max").setInt(opts, 1);
        optsc.getField("port").setInt(opts, 3000);
        optsc.getField("environment").set(opts, "development");
        optsc.getField("appDir").set(opts, System.getProperty("test.home")+"/bookstore");
        Class gf = cl.loadClass("org.glassfish.scripting.gem.GlassFishMain");
        Method[] ma = gf.getMethods();
        Method start = gf.getMethod("start", optsc);
        assertNotNull(start);
        start.invoke(null, opts);
    }

    public void testNonDefaultStartup() {
        // Add your code here
    }

    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
    }

    @Override
    protected void setUp() throws Exception {
        //cl = new URLClassLoader()
    }

    private final URL absolutize(String path) throws MalformedURLException {
        File f = new File(path);
        String str = f.getAbsolutePath();
        return f.getAbsoluteFile().toURI().toURL();
    }



}
