#!/bin/bash
# Instalador Egor Ultra Glitch - versión estilizada y optimizada
INSTALL_PATH="/usr/local/bin/egor"

echo "🚀 Instalando Egor Ultra Glitch como comando global..."

# Crear script en /usr/local/bin
sudo tee $INSTALL_PATH >/dev/null <<'EOF'
#!/bin/bash
# Egor Ultra Glitch - versión optimizada
INTERFACE="enp3s0"

# Función para aplicar glitch con parámetros
apply_glitch() {
    local delay=$1 jitter=$2 loss=$3 dup=$4 corrupt=$5 reorder=$6
    sudo tc qdisc del dev $INTERFACE root 2>/dev/null
    sudo tc qdisc add dev $INTERFACE root netem delay "${delay}ms" "${jitter}ms" \
        distribution normal loss ${loss}% duplicate ${dup}% corrupt ${corrupt}% reorder ${reorder}%
}

# Niveles de glitch predefinidos
glitch_level() {
    case $1 in
        1) echo "✨ Glitch Level 1"; apply_glitch 9000 3000 30 20 5 0 ;;
        2) echo "⚡ Glitch Level 2"; apply_glitch 12000 5000 50 50 20 25 ;;
        3) echo "🔥 Glitch Level 3 (Ultra)"; apply_glitch 12000 5000 60 60 40 25 ;;
        max) echo "💥 Egor Max!"; apply_glitch 12000 5000 70 70 50 50 ;;
        chaos)
            if [[ -z $2 ]]; then echo "⏱ Debes indicar duración en segundos"; exit 1; fi
            echo "🌪 Egor Chaos por $2 segundos!"
            END=$((SECONDS+$2))
            while [ $SECONDS -lt $END ]; do
                DELAY=$((RANDOM%12000+8000))
                JITTER=$((RANDOM%5000+2000))
                LOSS=$((RANDOM%70+20))
                DUP=$((RANDOM%70+20))
                CORRUPT=$((RANDOM%50+5))
                REORDER=$((RANDOM%50+5))
                apply_glitch $DELAY $JITTER $LOSS $DUP $CORRUPT $REORDER
                sleep 1
            done
            ;;
        off) echo "🛑 Desactivando todo"; sudo tc qdisc del dev $INTERFACE root 2>/dev/null ;;
        *) echo "❌ Nivel inválido. Usa 1,2,3,max,chaos <s> o off." ;;
    esac
}

# Ping personalizado
custom_ping() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        echo "📶 Ping custom: $1 ms"
        sudo tc qdisc del dev $INTERFACE root 2>/dev/null
        sudo tc qdisc add dev $INTERFACE root netem delay "${1}ms"
    else
        echo "❌ Ping inválido"
    fi
}

# Glitch + ping combo
glitch_plus_ping() {
    if [[ $1 =~ ^[0-9]+$ ]] && [[ $2 =~ ^[0-9]+$ ]]; then
        echo "🔀 Combo: glitch nivel $1 + ping $2 ms"
        case $1 in
            1) apply_glitch $2 3000 30 20 5 0 ;;
            2) apply_glitch $2 5000 50 50 20 25 ;;
            3) apply_glitch $2 5000 60 60 40 25 ;;
            max) apply_glitch $2 5000 70 70 50 50 ;;
            *) echo "❌ Nivel inválido"; exit 1 ;;
        esac
    else
        echo "❌ Debes indicar nivel de glitch y ping en ms"
    fi
}

# Main
case $1 in
    glitch) glitch_level $2 $3 ;;
    ping)
        [[ $2 == "off" ]] && sudo tc qdisc del dev $INTERFACE root 2>/dev/null
        custom_ping $2
        ;;
    combo) glitch_plus_ping $2 $3 ;;
    off) sudo tc qdisc del dev $INTERFACE root 2>/dev/null; echo "🛑 Todo desactivado" ;;
    *) echo -e "Uso de Egor Ultra Glitch:\n"\
"  egor glitch 1|2|3|max|chaos <s>|off\n"\
"  egor ping <ms>|off\n"\
"  egor combo <nivel> <ping>\n"\
"  egor off"
esac
EOF

# Hacer ejecutable
sudo chmod +x $INSTALL_PATH

echo "✅ Instalación completa! Usa 'egor' como comando global:"
echo "  egor glitch 1       # Glitch leve"
echo "  egor glitch 3       # Glitch ultra"
echo "  egor glitch max     # Egor Max"
echo "  egor glitch chaos 30 # Chaos 30 s"
echo "  egor ping 9000      # Ping custom"
echo "  egor combo 2 12000  # Glitch nivel 2 + ping 12 s"
echo "  egor off            # Desactivar todo"
