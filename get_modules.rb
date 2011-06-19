#!/usr/bin/ruby
Modules={
# 'autofs'=> 'git://puppet-modules.git.puzzle.ch/module-autofs.git', 
# 'amanda'=> 'git://puppet-modules.git.puzzle.ch/moduleamanda.git', 
# 'ant'=> 'git://puppet-modules.git.puzzle.ch/module-ant.git', 
# 'awstats'=> 'git://puppet-modules.git.puzzle.ch/moduleawstats.git', 
# 'cron'=> 'git://puppet-modules.git.puzzle.ch/module-cron.git', 
# 'cups'=> 'git://puppet-modules.git.puzzle.ch/module-cups.git', 
'dnsmasq'=> 'git://github.com/ngiger/puppet-dnsmasq.git',
'elexis'=> 'git://github.com/ngiger/puppet-elexis.git',
# 'git'=> 'git://puppet-modules.git.puzzle.ch/module-git.git', 
# 'java'=> 'git://puppet-modules.git.puzzle.ch/module-java.git', 
# 'logrotate'=> 'git://puppet-modules.git.puzzle.ch/module-logrotate.git', 
'motd'=> 'git://puppet-modules.git.puzzle.ch/module-motd.git', 
# 'network'=> 'git://puppet-modules.git.puzzle.ch/module-network.git',
'nginx'=> 'git://github.com/ngiger/puppet-nginx.git',
# 'openvpn'=> 'git://puppet-modules.git.puzzle.ch/module-openvpn.git', 
'postgres'=> 'git://github.com/ngiger/puppet-postgres.git', 
# 'rails'=> 'git://puppet-modules.git.puzzle.ch/module-rails.git', 
# 'subversion'=> 'git://puppet-modules.git.puzzle.ch/module-subversion.git',
# 'sshd'=> 'git://puppet-modules.git.puzzle.ch/module-sshd.git', 
# 'sshjump'=> 'git://puppet-modules.git.puzzle.ch/module-sshjump.git', 
# 'sudo'=> 'git://puppet-modules.git.puzzle.ch/module-sudo.git', 
# 'tftp'=> 'git://puppet-modules.git.puzzle.ch/module-tftp.git', 
# 'user'=> 'git://puppet-modules.git.puzzle.ch/module-user.git', 
# 'webhosting'=> 'git://puppet-modules.git.puzzle.ch/module-webhosting.git',
'x2go'=> 'git://github.com/ngiger/puppet-x2go.git',
}
#  git://puppet-modules.git.puzzle.ch/module-postgres.git
require 'fileutils'

def addSubmodule(m, from)
    cmd = "git submodule add #{from} modules/#{m}"
    puts cmd
    system(cmd)
#    cmd = "git clone #{from} modules/#{m}" ??
#    readme = "#{mDir}/README"
#    if !File.exists?(readme)
#      File.open(readme).puts("Cloned from #{from} at #{Time.now}")
end

Modules.each{
 |m, from|
  mDir = "modules/#{m}"
  if !File.exists?(mDir) then
    addSubmodule(m, from)
  end
}

require 'rubygems'
require 'inifile' # must be installed via gem install inifile
sub=IniFile.new(".gitmodules")
Modules.each{
 |m, from|
   if !sub["submodule \"modules/#{m}\""] or !sub["submodule \"modules/#{m}\""]['url']
    addSubmodule(m, from)
  else
   wo = from.index(sub["submodule \"modules/#{m}\""]['url'])
   if !wo
   then
     puts "patch #{m} => #{from}"
     sub["submodule \"modules/#{m}\""]['url'] = from
   end
  end
}
sub.save
cmd = "git submodule sync"
system(cmd)
system("grep dnsmasq .gitmodules .git/config")

TODO = <<EOF
http://jtrancas.wordpress.com/2011/02/06/git-submodule-location/
git config submodule.modules/nginx.url https://github.com/ngiger/puppet-nginx
1) Edit the .gitmodules file, and change the URL for the submodules which changed.

2) In your source tree’s root run:
1	user@host:/path/to/repo$ git submodule sync

3) Then run git init to update the project’s repository configuration with the new URLs:
1	user@host:/path/to/repo$ git submodule init

And it’s done, now you can continue pushing and pulling your submodules with no problems :)
sub['submodule "modules/autofs"'].inspect
 => "{\"path\"=>\"modules/autofs\", \"url\"=>\"git://puppet-modules.git.puzzle.ch/module-autofs.git\"}" 
sub['submodule "modules/autofs"']['url']
 => "git://puppet-modules.git.puzzle.ch/module-autofs.git" 
EOF
