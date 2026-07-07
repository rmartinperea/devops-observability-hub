#  DevOps Observability Hub: Laboratorio de Monitoreo & Hardening

Este es un laboratorio local de **Infraestructura como Código (IaC)** y **Observabilidad**. Está diseñado para simular cómo funciona el monitoreo de servidores y bases de datos en el mundo real, manejando telemetría automática, persistencia real de datos y aplicando capas de seguridad para proteger el entorno contra accesos no autorizados.

---

##  Arquitectura del Sistema

El proyecto levanta un ecosistema de **7 servicios** totalmente interconectados a través de una red privada virtual de Docker (`red-infraestructura`). 

Para proteger los datos sensibles, **he aislado la red por dentro**, lo que significa que los servicios hablan entre sí en secreto y los únicos puntos expuestos al exterior de forma segura son Grafana y pgAdmin.

```text
       [ Navegador Web ] ───► (Puerto 8080/80) ───► [ pgAdmin (Gestión) ]
               │                                           │
               │ (Puerto 3000 protegido)                   ▼
               ▼                                   [ PostgreSQL (Datos) ]
       [ Grafana (Pintor) ]                                ▲
               ▲                                           │
               │ (Conexión de Red Interna)                 │ (Métricas SQL)
               │                                           │
       [ Prometheus (Cerebro) ] ◄────────────────── [ Postgres Exporter ]
               ▲            ▲            ▲
               │            │            │
         (Métricas)     (Métricas)   (Métricas)
               │            │            │
         ┌─────┴─────┐┌─────┴─────┐┌─────┴─────┐
         │Node Export││ cAdvisor  ││Simulador  │
         │ (Host/Red)││(Contened.)││ CPU (Bash)│
         └───────────┘└───────────┘└───────────┘
```

###  Componentes de la Infraestructura

1. **Capa de Visualización (Grafana):** Nuestro panel de control centralizado. Es el punto de control expuesto y está conectado mediante un webhook directo con un bot de **Slack (ChatOps)** para alertar al equipo al instante en caso de incidentes.
2. **Motor de Telemetría (Prometheus):** Que lee, almacena e indexa todas las métricas de rendimiento y reglas de alerta.
3. **Capa de Datos (PostgreSQL):** Almacenamiento persistente que simula la base de datos transaccional de negocio de una empresa real (`mi_app_db`).
4. **Capa de Gestión de Datos (pgAdmin):** Para editar y lanzar consultas SQL a la base de datos de forma gráfica sin usar la terminal [c8b2189b-0985-4317-a333-43d8251de7ae].
5. **Agentes de Recolección (Los Traductores):**
   * **Node Exporter:** Con el que medimos la salud del hardware general (CPU, RAM, discos de la máquina).
   * **cAdvisor:** Vigila el consumo de recursos de cada contenedor de Docker de forma individual.
   * **Postgres Exporter:** Se conecta internamente a PostgreSQL para extraer estadísticas de rendimiento y consultas [c8b2189b-0985-4317-a333-43d8251de7ae].
6. **Simulador Autónomo de Estrés (Bash + Dockerfile):** Un microservicio programado que inyecta picos de carga y caídas simuladas para auditar las alertas de Slack.

---

##  Buenas Prácticas de Seguridad Implementadas (Hardening)

* **Principio de Menor Privilegio (Bloqueo de Puertos):** Se han eliminado las directivas `ports` externas en PostgreSQL, Prometheus, cAdvisor y Node Exporter. Todo el tráfico viaja aislado por la red interna de Docker. El exterior solo ve las interfaces de gestión (Grafana y pgAdmin).
* **Protección contra Llenado de Disco (Anti-DoS):** Limitamos la retención de Prometheus mediante comandos explícitos (`--storage.tsdb.retention.size=5GB`) para evitar corrupciones de disco.
* **Persistencia Segura No-Root:** Se ha configurado la propiedad de los volúmenes locales mediante identificadores de usuario (`UID`) específicos de cada servicio para evitar fugas de permisos en el Host [c8b2189b-0985-4317-a333-43d8251de7ae]:
  * Grafana mapeado al UID `472:472` [c8b2189b-0985-4317-a333-43d8251de7ae].
  * pgAdmin mapeado al UID `5050:5050` [c8b2189b-0985-4317-a333-43d8251de7ae].

---

##  Métricas Clave Diseñadas (PromQL)

Para rescatar los paneles de la comunidad obsoletos y adaptarlos a las etiquetas de contenedores locales, se han diseñado y refactorizado las siguientes consultas de telemetría [c8b2189b-0985-4317-a333-43d8251de7ae]:

* **Consumo de CPU por Contenedor Individual (%):**
  Aprovecha cAdvisor para calcular la tasa de uso de CPU filtrada por la variable de selección de Grafana:
  ```promql
  sum(rate(container_cpu_usage_seconds_total{name=~"\$container"}[5m])) by (name) * 100
  ```
* **Uso de Memoria RAM Real por Contenedor (MB):**
  Transforma los bytes puros recopilados por cAdvisor a Megabytes reales legibles por el Sysadmin:
  ```promql
  sum(container_memory_usage_bytes{name=~"\$container"}) by (name) / 1024 / 1024
  ```
* **Detección de Caídas e Intercepción de Alertas:**
  Consulta puente que permite a Grafana vigilar si el motor de Prometheus tiene alguna regla activa en estado crítico (`firing`) para disparar el Bot de Slack [c8b2189b-0985-4317-a333-43d8251de7ae]:
  ```promql
  ALERTS{alertname="ServidorCaido", alertstate="firing"}
  ```

---

##  Configuración del Sistema de Alertas (ChatOps con Slack)

El laboratorio cuenta con un sistema de alertas en tiempo real optimizado para entornos de desarrollo. Se ha configurado la **Política de Notificaciones por Defecto (Default Policy)** con tiempos de espera reducidos para garantizar avisos inmediatos ante fallos [c8b2189b-0985-4317-a333-43d8251de7ae]:
* **Group wait:** `2s` (Espera inicial antes de enviar la primera alerta a Slack) [c8b2189b-0985-4317-a333-43d8251de7ae].
* **Group interval:** `5s` (Tiempo de respuesta para agrupar nuevos incidentes) [c8b2189b-0985-4317-a333-43d8251de7ae].
* **Comportamiento No-Data:** Configurado en `OK` para mitigar falsos positivos por micro-cortes o silencios en las métricas estables [c8b2189b-0985-4317-a333-43d8251de7ae].

---

##  Despliegue Rápido (Quickstart)

### Requisitos Previos
* Docker y Docker Compose instalados.
* Compatible con Linux y **WSL2 (Windows Subsystem for Linux)**.

### Instrucciones de Preparación de Persistencia
Antes de levantar los servicios, debes crear las carpetas de datos en tu proyecto y asignarles los permisos de los usuarios internos de los contenedores para garantizar la persistencia de tus paneles y conexiones [c8b2189b-0985-4317-a333-43d8251de7ae]:
```bash
# 1. Crear directorios para persistencia de datos
mkdir -p grafana/data pgadmin-data postgres-data

# 2. Asignar los permisos correspondientes (UIDs oficiales)
sudo chown -R 472:472 ./grafana/data
sudo chown -R 5050:5050 ./pgadmin-data
```

### Ejecución
1. Levanta toda la infraestructura blindada en segundo plano con un solo comando:
   ```bash
   docker compose up -d --remove-orphans
   ```
2. Acceso a las aplicaciones desde tu navegador:
   * **Grafana (Monitoreo & Alertas):** `http://localhost:3000` (`admin` / `admin`)
   * **pgAdmin (Gestión SQL):** `http://localhost:8080` (Usa tu correo/clave del Compose)

---

##  Solución de Problemas Frecuentes (Troubleshooting)

* **¿Por qué los paneles de cAdvisor muestran "No Data" al importarlos?**
  Las plantillas comunitarias suelen buscar etiquetas de Docker empresariales como `container_label_com_docker_compose_service`. En este laboratorio solucionamos este problema editando las variables del panel en Grafana y reescribiendo la consulta nativa a `label_values(container_last_seen, name)` [c8b2189b-0985-4317-a333-43d8251de7ae].
* **pgAdmin da error `failed to resolve host` al intentar conectar con PostgreSQL:**
  Estás intentar usar `localhost` o el nombre de la base de datos como dirección del servidor. Dentro de la red interna de Docker debes usar el nombre del servicio definido en el `docker-compose.yml`, que es **`db`** [c8b2189b-0985-4317-a333-43d8251de7ae].
* **El bot de Slack envía alertas con valor `[no value]` de forma aleatoria:**
  Es el comportamiento `No Data` de Grafana [c8b2189b-0985-4317-a333-43d8251de7ae]. Se soluciona editando la regla de alerta en la interfaz web de Grafana y cambiando el campo *"Alert state if no data"* de `No Data` a `OK` [c8b2189b-0985-4317-a333-43d8251de7ae].
