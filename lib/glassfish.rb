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
require 'java'
require 'glassfish-gem.jar'
require 'glassfish.jar'
require 'akuma.jar'
require 'yaml'
require 'ftools'
require 'version'


#
#Invokes and runs GlassFish
#
module GlassFish
  class Server
    import "org.glassfish.scripting.gem.GlassFishMain"
    import "org.glassfish.scripting.gem.Options"

    def startup(args)
      if args[:log_level] > 4
        puts "Arguments: "
        args.each do |k, v| 
          puts "\t#{k}=>#{v}"
        end
      end

      opts = Options.new()
      opts.runtimes = args[:runtimes]
      opts.runtimes_min = args[:runtimes_min]
      opts.runtimes_max = args[:runtimes_max]
      opts.environment = args[:environment]
      opts.port = args[:port]
      opts.contextRoot = args[:contextroot]
      opts.appDir = args[:app_dir]
      opts.daemon = args[:daemon]
      opts.pid = args[:pid]
      opts.log = args[:log]
      opts.log_console = args[:log_console]
      opts.domainDir = args[:domain_dir]
      opts.log_level = args[:log_level]
      opts.jvm_opts = args[:jvm_options]
      gf = GlassFishMain.start opts
    end
  end
end