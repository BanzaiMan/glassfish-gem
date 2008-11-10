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

require 'rdoc_usage'
require 'getoptlong'

#
# Parses command line options
#
class CommandLineParser
  def init_opts
    @@config ||= {
            :runtimes     => '1',
            :runtimes_min => '1',
            :runtimes_max => '1',
            :contextroot  => '/',
            :environment  => "development",
            :app_dir      => Dir.pwd,
            :port         => 3000
    }
  end

  def parse
    config = init_opts
    opts = GetoptLong.new(
            [ '--port', '-p', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--environment', '-e', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--contextroot', '-c', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--runtimes', '-n', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--runtimes_min', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--runtimes_max', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--version', '-v', GetoptLong::NO_ARGUMENT ],
            [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
    )

    opts.each do |opt, arg|
      case opt
      when '--version'
        require 'version'
        puts "GlassFish gem version: #{GlassFish::VERSION::STRING}\nhttp://glassfishgem.rubyforge.org"
        exit(0)
      when '--help'
        RDoc::usage
      when '--contextroot'
        config[:contextroot] = arg
      when '--port'
        config[:port] = arg.to_i
      when '--environment'
        config[:environment] = arg
      when '--runtimes'
        config[:runtimes] = arg
      when '--runtimes-min'
        config[:runtimes_min] = arg
      when '--runtimes-max'
        config[:runtimes_min] = arg
      end
    end    
    config[:app_dir] = ARGV.shift unless ARGV.empty?
    config
  end
end
