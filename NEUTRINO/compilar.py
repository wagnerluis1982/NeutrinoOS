#!/usr/bin/env python
# encoding=utf-8
#
# Copyright (C) 2011-2012
# Alisson Linhares de Carvalho, Wagner Luis de Araújo Menezes Macedo.
# All rights reserved.
#
# This file is part of the neutrino kernel.
#
# The neutrino kernel is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# The neutrino kernel is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with the neutrino kernel. If not, see <http://www.gnu.org/licenses/>.
#
#-------------------------------------------------------------------------------

import getopt
import glob
import os
import sys

# Funções úteis ao processo de compilação
def right_sep(arg):
	return arg.replace("/", os.sep)

def execute(command, to_exit=True):
	variables = globals()
	variables.update(locals())
	
	if os.system(right_sep(command).format(**variables)) != 0 and to_exit:
		sys.exit(1)

def clear():
	if os.name == "nt":
		execute("cls")
	elif os.name == "posix":
		execute("clear")

def rm(arg):
	# Remove arquivos por padrão. Ex: *.txt
	for file_node in glob.glob(right_sep(arg)):
		os.remove(file_node)

def usage():
	print "Uso: %s [OPÇÃO]..." % sys.argv[0]
	print "Script de compilação do Neutrino OS"
	print "\nArgumentos:",
	print """
	-m --mode         modo de operação para ser compilado o Kernel Neutrino
	-d --debug        aciona o modo debug. É o mesmo que --mode debug
	-v --vbox         inicia o VirtualBox após a compilação com sucesso
	-n --vmname=NOME  informa um nome diferente para a VM ao iniciar o VirtualBox o padrão é "NeutrinoOS". Essa opção só tem valor quando usada em conjunto com --vbox
	-h --help         mostra esta ajuda e finaliza"""

# Parse das opções de linha de comando
try:
	opts, args = getopt.getopt(sys.argv[1:],
	# opções curtas
	"hvn:m:d",
	# opções longas
	["help", "vbox", "vmname=", "mode=", "debug"])

except getopt.GetoptError, err:
	print err
	usage()
	sys.exit(2)

start_vbox = False
vmname = None
operation_mode = "GRAPHICS"
for option, arg in opts:
	if option in ("-v", "--vbox"):
		start_vbox = True
	elif option in ("-n", "--vmname"):
		vmname = arg
	elif option in ("-d", "--debug"):
		operation_mode = "DEBUG"
	elif option in ("-m", "--mode"):
		operation_mode = arg.upper()
	elif option in ("-h", "--help"):
		usage()
		sys.exit(0)

# Parâmetros de compilação
FLAGS_GCC = "-fno-exceptions -fno-stack-protector -fno-rtti -fpermissive -m32"
OPTIONS_GCC = right_sep("-I LIB/ -I LIB/UTIL -I LIB/GUI -I LIB/SYS -g -O2 -DNDEBUG")
OPTIONS_LD = right_sep("-melf_i386 -T LIB/link.ld BIN/crt0.O")

# Entra no diretório de compilação
DIR = os.path.dirname(sys.argv[0])
if DIR != "":
	os.chdir(DIR)

# Se a pasta BIN não existir, cria
if not os.path.exists("BIN"):
	os.mkdir("BIN")
clear()

print "1. Compilando dependencias"
print " 1.1. Imagens"
execute("nasm -f bin KERNEL/GUI/NIFS.ASM -o BIN/NIF.BIN")

print " 1.2. CRT0"
execute("nasm -faout LIB/crt0.s -o BIN/crt0.O")

# Loop sobre todos os diretórios dentro de APPS, compilando quando acha main.cpp
print "2. Compilando programas"
for app_dir in os.listdir("APPS"):
	if os.path.isfile(os.path.join("APPS", app_dir, "main.cpp")):
		app_name = app_dir

		execute("g++ {OPTIONS_GCC} -c APPS/{app_dir}/main.cpp {FLAGS_GCC} -o BIN/{app_name}.O")
		execute("ld {OPTIONS_LD} BIN/{app_name}.O -o BIN/{app_name}.BIN")
		
		# Progresso
		sys.stdout.write(".")
		sys.stdout.flush()
print

print "3. Compilando kernel"
execute("nasm -f bin KERNEL/KERNEL.ASM -dOPERATION_MODE=%s_MODE -o BIN/KERNEL.BIN" % operation_mode)
execute("nasm -f bin KERNEL/LOADER.ASM -o BIN/LOADER.BIN")

# Remove todos os arquivos ISO existentes
rm("BIN/*.ISO")

print "4. Gerando imagem de disquete"
execute("nasm -f bin APPS/INSTALLER/MAIN.ASM -o BIN/INSTALLER.BIN")
execute("nasm -f bin APPS/INSTALLER/LOADER.ASM -o BIN/FLOPPY_DISK.IMG")

print "5. Gerando imagem de cd"
execute("mkisofs -quiet -o BIN/CD.ISO -A NeutrinoOS -b FLOPPY_DISK.IMG BIN/")

print "6. Gerando live cd"
execute("nasm -f bin KERNEL/LOADER.ASM -dBOOT_FROM=CD -o BIN/LOADER.BIN")
execute("mkisofs -quiet -R -no-emul-boot -boot-load-size 1 -o BIN/LIVE.ISO -A NeutrinoOS -b LOADER.BIN BIN/")

# Remove arquivos temporários
rm("BIN/*.BIN")
rm("BIN/*.O")

# Inicia a máquina virtual
if start_vbox:
	vmname = vmname or "NeutrinoOS"
	execute("virtualbox --startvm " + vmname, to_exit=False)

print "7. Fim"
