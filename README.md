# Laboratorio de Observabilidad y Monitoreo de Infraestructura con Docker

Este repositorio contiene un entorno de telemetría profesional completamente contenedorizado, diseñado para la recolección, almacenamiento y visualización de métricas de sistemas en tiempo real. Combina la monitorización de bases de datos relacionales y el estándar industrial de bases de datos de series temporales (TSDB).

## 🚀 Arquitectura del Sistema

El proyecto despliega una arquitectura desacoplada mediante microservicios orquestados:

*   **Capa de Visualización (Grafana):** Panel de control centralizado con visualización analítica.
*   **Capa de Telemetría (Prometheus + Google cAdvisor):** Recolección automatizada y almacenamiento eficiente (TSDB) de los signos vitales reales (CPU/Memoria) del hardware y contenedores.
*   **Capa de Datos de Aplicación (PostgreSQL + pgAdmin):** Almacenamiento persistente de datos del negocio y administración visual de bases de datos relacionales.
*   **Capa de Automatización (Simulador Bash/Dockerfile):** Un microservicio propio que inyecta de forma autónoma métricas lógicas y simula incidentes críticos (estrés de CPU y caídas de servicio) para validar la reactividad del monitoreo.

## 🛠️ Tecnologías Utilizadas

*   **Orquestación:** Docker, Docker Compose, Dockerfile
*   **Monitoreo:** Prometheus (PromQL), Google cAdvisor
*   **Bases de Datos:** PostgreSQL (SQL, Time Series), pgAdmin4
*   **Visualización:** Grafana (Dashboards as Code)
*   **Automatización:** Bash Scripting (Linux)

## 📦 Estructura del Proyecto

```text
├── docker-compose.yml       # Orquestación de toda la infraestructura de red y servicios
├── Dockerfile               # Compilación del contenedor autónomo del simulador
├── simulador.sh             # Script de automatización de cargas e incidentes lógicos
├── prometheus.yml           # Configuración del intervalo de scrape y targets de telemetría
└── dashboard-infraestructura.json # Respaldo del Dashboard de Grafana listo para importar
```

## ⚡ Instrucciones de Despliegue

1. Clona este repositorio en tu máquina local.
2. Ejecuta el siguiente comando para compilar el simulador y levantar toda la infraestructura en segundo plano:
   ```bash
   docker compose up -d --build
   ```
3. Accede a las interfaces web locales:
   * **Grafana:** `http://localhost:3000` (Credenciales por defecto: `admin` / `admin`)
   * **pgAdmin:** `http://localhost:8080` (O el puerto configurado)
   * **Prometheus Targets:** `http://localhost:9090/targets`

## 📊 Capacidades Demostradas en este Lab

*   **Infraestructura como Código (IaC):** Despliegue reproducible de entornos mediante Docker Compose con redes virtuales dedicadas y volúmenes persistentes para evitar la pérdida de datos.
*   **DNS Interno de Docker:** Interconexión de servicios utilizando resolución de nombres de contenedores en lugar de IPs estáticas.
*   **Monitoreo con PromQL y SQL:** Creación de consultas optimizadas para formatear datos en series temporales independientes por servidor.
*   **Gestión de Incidentes:** Simulación de picos de carga (Thresholds) y caídas de nodos para pruebas de estrés de los sistemas de alertas visuales.
