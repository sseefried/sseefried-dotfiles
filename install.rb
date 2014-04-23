#!/usr/bin/env ruby

unless RUBY_VERSION =~ /^2\./
  puts "This script must be run with Ruby version 2 or later"
end


THIS_DIR = File.dirname(File.expand_path(__FILE__))

SYMLINKS = [ { :file => "#{THIS_DIR}/symlinks/dot_bash_profile",     :link => "#{ENV['HOME']}/.bash_profile" },
             { :file => "#{THIS_DIR}/symlinks/dot_emacs",            :link => "#{ENV['HOME']}/.emacs"        },
             { :file => "#{THIS_DIR}/symlinks/emacs.d",              :link => "#{ENV['HOME']}/.emacs.d"      },
             { :file => "#{THIS_DIR}/symlinks/dot_ssh_slash_config", :link => "#{ENV['HOME']}/.ssh/config"   },
             { :file => "#{THIS_DIR}/symlinks/dot_gitconfig",        :link => "#{ENV['HOME']}/.git_config"   }
           ]

SYMLINKS.each do |sl|
  if File.exist?(sl[:link])
    if !File.symlink?(sl[:link])
      puts "ERROR: File #{sl[:link]} exists but it's not a symlink"
      puts "       Manually resolve this conflict and re-run this script."
    elsif File.readlink(sl[:link]) != sl[:file]
      puts "ERROR: File #{sl[:link]} exists but is not symlinked into dotfiles."
      puts "       Manually resolve this conflict and re-run this script."
    else
#      puts "[+] '#{sl[:link]}'"
#      puts "       already symlinked to"
#      puts "    '#{sl[:file]}'"
    end

  else # File doesn't exist
#    puts "[+] Symlinking '#{sl[:link]}'"
#    puts "      to"
#    puts "    '#{sl[:file]}'"
    system("mkdir -p #{File.dirname(sl[:link])}")
    system("rm -f #{sl[:link]}") # Remove dead links
    system("ln -s #{sl[:file]} #{sl[:link]}")
  end

end

existing_machines = Dir["#{THIS_DIR}/bash/machines/*/"].collect { |m| File.basename(m) }
default_machine = existing_machines.member?(ENV['MACHINE']) ? ENV['MACHINE'] : existing_machines.first
printf "Machines: #{existing_machines.join(", ")}\n"
printf "What is this machine called? [#{default_machine}]:"

machine = gets
machine.strip!

machine = default_machine if machine.length == 0

unless existing_machines.member?(machine)
  puts "Machine '#{machine}' does not exist"
  exit 1
end

bashrc_string = [ "# THIS FILE HAS BEEN AUTOMATICALLY GENERATED BY dotfiles.",
                  "# DO NOT EDIT IT DIRECTLY",
                  "export MACHINE=#{machine}",
                  "source #{THIS_DIR}/bash/bashrc" ].join("\n")

printf("About to overwrite #{ENV['HOME']}/.bashrc with:\n\n%s\n\nIs this okay?[y/N]: ", bashrc_string)
s = gets

if s =~ /y/ || s =~ /Y/
  File.open("#{ENV['HOME']}/.bashrc", "w") { |f| f.write(bashrc_string) }
end
