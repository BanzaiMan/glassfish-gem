#--
#DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
#Copyright 1997-2007 Sun Microsystems, Inc. All rights reserved.
#
#The contents of this file are subject to the terms of either the GNU
#General Public License Version 2 only ("GPL") or the Common Development
#and Distribution License("CDDL") (collectively, the "License").  You
#may not use this file except in compliance with the License. You can obtain
#a copy of the License at https://glassfish.dev.java.net/public/CDDL+GPL.html
#or glassfish/bootstrap/legal/LICENSE.txt.  See the License for the specific
#language governing permissions and limitations under the License.
#
#When distributing the software, include this License Header Notice in each
#file and include the License file at glassfish/bootstrap/legal/LICENSE.txt.
#Sun designates this particular file as subject to the "Classpath" exception
#as provided by Sun in the GPL Version 2 section of the License file that
#accompanied this code.  If applicable, add the following below the License
#Header, with the fields enclosed by brackets [] replaced by your own
#identifying information: "Portions Copyrighted [year]
#[name of copyright owner]"
#
#Contributor(s):
#
#If you wish your version of this file to be governed by only the CDDL or
#only the GPL Version 2, indicate your decision by adding "[Contributor]
#elects to include this software in this distribution under the [CDDL or GPL
#Version 2] license."  If you don't indicate a single choice of license, a
#recipient has the option to distribute your version of this file under
#either the CDDL, the GPL Version 2 or to extend the choice of license to
#its licensees as provided above.  However, if you add GPL Version 2 code
#and therefore, elected the GPL Version 2 license, then the option applies
#only if the new code is made subject to such option by the copyright
#holder.
#++

require 'glassfish.jar'

#
#Invokes and runs GlassFish
#
module GlassFish
  class Server
    import com.sun.enterprise.glassfish.bootstrap.ASMain    
    def startup(args)
      #set jruby runtime property
      java.lang.System.setProperty("jruby.runtime", args[:runtimes].to_s)
      java.lang.System.setProperty("jruby.runtime.min", args[:runtimes_min].to_s)
      java.lang.System.setProperty("jruby.runtime.max", args[:runtimes_max].to_s)
      java.lang.System.setProperty("rails.env", args[:environment])
      java.lang.System.setProperty("jruby.gem.port", args[:port].to_s)
      java.lang.System.setProperty("GlassFish_Platform", "Static")
      #java.lang.System.setProperty("glassfish.static.cache.dir", args[:app_dir]+"/tmp")

      ASMain.main([args[:app_dir], "--contextroot", args[:contextroot]].to_java(:string))
    end
  end
end
