#!/bin/bash
#    Copyright (C) 2008 - Nícolas Wildner <nicolasgaucho@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation version 3 of the License
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

USO="Uso: check_mount.sh -p [ponto_de_montagem OU dispositivo] -t [tipo de filesystem]"

# Verifica se o numero de argumentos é maior que 3( -p arg1 -t arg2)

if [ $# -gt 3 ]; then
	while getopts "hp:t:"  OPCOES; do
		case $OPCOES in
			h ) echo $USO exit 1;;
			p ) PONTOMONTAGEM=$OPTARG;;
			t ) FILESYSTEM=$OPTARG;;
			? ) echo $USO 
			     exit 1;;
			* ) echo $USO
			     exit 1;;
		esac
	done
else echo $USO; exit 3
fi

# Verifica que os pontos de montagem fornecidos pelo usuário constam no mount
# (utilizado MOUNT, pois nem todos *NIX possuem /etc/mtab)

EXECUTA=`mount | grep $FILESYSTEM  | grep $PONTOMONTAGEM 2> /dev/null`
	if [ -n "$EXECUTA"  ]; then echo "Ponto de montagem $PONTOMONTAGEM está OK"; exit 0
	else echo "Ponto de montagem $PONTOMONTAGEM não está montado"; exit 2 
fi
