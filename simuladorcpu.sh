#!/bin/bash
echo "Iniciando simuladorcpu nativo en Docker..."

# Esperar a que la base de datos esté lista para aceptar conexiones
sleep 5

while true; do
    CPU_WEB=$((RANDOM % 40 + 20))
    CPU_DB=$((RANDOM % 55 + 40))
    MEM_WEB=$((RANDOM % 30 + 50))
    MEM_DB=$((RANDOM % 20 + 70))

    # Conexión directa usando las variables de entorno de red de Postgres
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c "
    INSERT INTO metricas_servidor (nombre_servidor, uso_cpu, uso_memoria, estado) 
    VALUES ('srv-web-01', $CPU_WEB, $MEM_WEB, 'OK'), ('srv-db-01', $CPU_DB, $MEM_DB, 'OK');" > /dev/null

    echo "[$(date +%T)] Métricas inyectadas con éxito."
    sleep 5
done

