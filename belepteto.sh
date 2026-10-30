#!/bin/sh

USERS="user.dat"
ROOMS="belepteto.dat"

hibas_hasznalat()
{
	echo "\nHibás használat!\n"
	case $1 in
	"l") echo "-lista használata: -lista" ;;
	"f") echo "-felismer használata: -felismer <arckép>" ;;
	"b") echo "-bemehet használata: -bemehet <arckép> <terem>" ;;
	*) echo "Adjon meg egy kapcsolót: \n\t-lista\n \t-felismer <arckép>\n \t-bemehet <arckép> <terem>" ;;
	esac
	echo ""
	exit 1
}

kep_keres()
{
	res=1
	line=$(grep -w "^[^;]*$1" "$USERS" | cut -d';' -f2-)
	if [ -n "$line" ] ; then
		res="$line"
	fi
	echo "$res"
}

# $1 - user $2 - terem
van_joga()
{
	res=0
	if [ "$1" = "A" ] ; then
		res=1
	elif [ "$1" = "B" ] ; then
		case $2 in
		B|C) res=1 ;;
		esac
	elif [ "$1" = "$2" ] ; then
		res=1
	fi
	echo "$res"
}

lista_kapcsolo()
{
	if [ $# -gt 1 ] ; then
		hibas_hasznalat "l"
	fi
	echo ""
	cut -d',' -f1 "$ROOMS"
	echo ""
	return 0
}

felismer_kapcsolo()
{
	code=0
	if [ $# -ne 2 ] ; then
		hibas_hasznalat "f"
	fi
	echo ""
	megold=$(kep_keres "$2")
	if [ "$megold" = "1" ] ; then
		echo "A képen látható személy nem szerepel a felhasználók között."
		code=1
	else
		echo "$megold" | tr ';' ' '
	fi
	echo ""
	return "$code"
}

bemehet_kapcsolo()
{
	if [ $# -ne 3 ] ; then
		hibas_hasznalat "b"
	fi
	echo ""
	megold=$(kep_keres "$2")
	if [ "$megold" = "1" ] ; then
		echo "A képen látható személy nem szerepel a felhasználók között.\n"
		return 1
	fi
	user_jog=$(echo "$megold" | cut -d';' -f3)
	terem_jog=$(grep -w "^$3" "$ROOMS" | cut -d',' -f2)
	if [ -n "$terem_jog" ] ; then
		jogosulte=$(van_joga "$user_jog" "$terem_jog")
		if [ "$jogosulte" = "1" ] ; then
			echo "A képen látható személy beléphet."
		else
			echo "A képen látható személynek nincs kellő jogosultsága a belépéshez."
		fi
		echo ""
		return 0
	fi
	echo "A megadott terem nem létezik.\n"
	return 1
}

if [ $# -lt 1 ] ; then
	hibas_hasznalat
fi

if [ ! -f "$USERS" ] ; then
	echo "Hiányzik a ${USERS} fájl!"
	exit 1
elif [ ! -f "$ROOMS" ] ; then
	echo "Hiányzik a ${ROOMS} fájl!"
	exit 1
fi

case $1 in
"-lista")
	lista_kapcsolo "$@"
	;;
"-felismer")
	felismer_kapcsolo "$@"
	;;
"-bemehet")
	bemehet_kapcsolo "$@"
	;;
*)
	hibas_hasznalat
	;;
esac
exit 0
