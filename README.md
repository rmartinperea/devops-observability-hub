# devops-observability-hub
Laboratorio local de IaC y Observabilidad para Sysadmin. Gestiona persistencia de bases de datos relacionales y automatiza la recolección de telemetría con Prometheus y cAdvisor. Incluye paneles dinámicos en Grafana para analizar el rendimiento del sistema ante picos de estrés simulados. Arquitectura y código disponibles en el repositorio.


# Laboratorio de Observabilidad y Monitoreo de Infraestructura con Docker

Este repositorio contiene un entorno de telemetría profesional completamente contenedorizado, diseñado para la recolección, almacenamiento y visualización de métricas de sistemas en tiempo real. Combina la monitorización de bases de datos relacionales y el estándar industrial de bases de datos de series temporales (TSDB).

## Arquitectura del Sistema

El proyecto despliega una arquitectura desacoplada mediante microservicios orquestados:

*   **Capa de Visualización (Grafana):** Panel de control centralizado con visualización analítica.
*   **Capa de Telemetría (Prometheus + Google cAdvisor):** Recolección automatizada y almacenamiento eficiente (TSDB) de los signos vitales reales (CPU/Memoria) del hardware y contenedores.
*   **Capa de Datos de Aplicación (PostgreSQL + pgAdmin):** Almacenamiento persistente de datos del negocio y administración visual de bases de datos relacionales.
*   **Capa de Automatización (Simulador Bash/Dockerfile):** Un microservicio propio que inyecta de forma autónoma métricas lógicas y simula incidentes críticos (estrés de CPU y caídas de servicio) para validar la reactividad del monitoreo.

##  Tecnologías Utilizadas

*   **Orquestación:** Docker, Docker Compose, Dockerfile
*   **Monitoreo:** Prometheus (PromQL), Google cAdvisor
*   **Bases de Datos:** PostgreSQL (SQL, Time Series), pgAdmin4
*   **Visualización:** Grafana (Dashboards as Code)
*   **Automatización:** Bash Scripting (Linux)

##  Estructura del Proyecto

```text
├── docker-compose.yml       # Orquestación de toda la infraestructura de red y servicios
├── Dockerfile               # Compilación del contenedor autónomo del simulador
├── simulador.sh             # Script de automatización de cargas e incidentes lógicos
├── prometheus.yml           # Configuración del intervalo de scrape y targets de telemetría
└── dashboard-infraestructura.json # Respaldo del Dashboard de Grafana listo para importar
```

##  Instrucciones de Despliegue

1. Clona este repositorio en tu máquina local.
2. Ejecuta el siguiente comando para compilar el simulador y levantar toda la infraestructura en segundo plano:
   ```bash
   docker compose up -d --build
   ```
3. Accede a las interfaces web locales:
   * **Grafana:** `http://localhost:3000` (Credenciales por defecto: `admin` / `admin`)
   * **pgAdmin:** `http://localhost:8080` (O el puerto configurado)
   * **Prometheus Targets:** `http://localhost:9090/targets`

##  Capacidades Demostradas en este Lab





#  Enterprise Observability Lab & Infrastructure Hardening

Proyecto de infraestructura automatizada para la monitorización de servidores, simulación de estrés y securización de redes internas utilizando contenedores Docker. Diseñado bajo estándares profesionales de Sysadmin y DevOps para entornos de alta disponibilidad.

---

## 🛠️ Arquitectura del Sistema

El proyecto despliega un ecosistema compuesto por 7 microservicios interconectados a través de una red privada virtual de Docker (`red-infraestructura`), aislando los datos sensibles del exterior.

```text
       [ Navegador Web ]
               │  (Puerto 3000 protegido / Grafana)
               ▼
      ┌────────────────────────────────────────────────────────┐
      │                   RED DE DOCKER PRIVADA                │
      │                                                        │
      │   ┌───────────────┐        ┌───────────────────────┐   │
      │   │    Grafana    │◄───────┤ Prometheus (Métricas) │   │
      │   └───────────────┘        └───────────┬───────────┘   │
      │                                        │               │
      │         ┌──────────────────────────────┼───────────┐   │
      │         ▼                              ▼           ▼   │
      │  ┌───────────────┐              ┌─────────────┐ ┌─────────────┐
      │  │  PostgreSQL   │              │  cAdvisor   │ │Node Exporter│
      │  │ (Transacciones│              │(Contenedores)││ (Host/Red)  │
      │  └──────▲────────┘              └─────────────┘ └─────────────┘
      │         │                                              │
      │  ┌──────┴────────┐                                     │
      │  │ Simulador CPU │ (Inyección de Picos)                │
      │  └───────────────┘                                     │
      └────────────────────────────────────────────────────────┘
```

### Componentes de la Infraestructura
1. **Visualización y Alertas (Grafana):** Único punto de acceso expuesto al host. Consolida los paneles métricos y se integra con Slack para ChatOps.
2. **Motor de Métricas (Prometheus):** Base de datos de series temporales (TSDB) configurada con políticas estrictas de retención (máximo 7 días o 5 GB) para blindar el almacenamiento del servidor.
3. **Persistencia de Negocio (PostgreSQL + pgAdmin):** Almacenamiento relacional que simula el backend corporativo, integrado de forma interna en la red.
4. **Simulador Autónomo de Estrés (Bash + Docker):** Inyecta de forma automatizada picos lógicos de estrés en el procesador (CPU 99%) y caídas programadas del servicio para evaluar la resiliencia del sistema.
5. **Agentes de Recolección (cAdvisor + Node Exporter):** Monitorizan en tiempo real el consumo de hardware de los contenedores y el tráfico de red de la infraestructura.

---

## 🔒 Buenas Prácticas de Seguridad Implementadas (Hardening)

* **Principio de Menor Privilegio (Aislamiento de Puertos):** Se han eliminado las directivas `ports` hacia el sistema host en PostgreSQL, Prometheus, cAdvisor y Node Exporter. El tráfico viaja exclusivamente de forma interna dentro de la red aislada de Docker.
* **Mitigación de Denegación de Servicio (DoS) por Almacenamiento:** Configuración de límites máximos en la retención de métricas de Prometheus (`--storage.tsdb.retention.size=5GB`) previniendo el llenado accidental o malicioso del disco del servidor.

---

## 📊 Métricas Clave Diseñadas (PromQL)

Para la monitorización avanzada en Grafana se implementaron paneles basados en las siguientes consultas:

* **Velocidad de Escritura en Disco por Contenedores (MB/s):**
  ```promql
  sum(rate(container_fs_writes_bytes_total[5m])) / 1024 / 1024
  ```
* **Estado de Salud de los Nodos (Up/Down):**
  ```promql
  up
  ```

---

## 🚀 Despliegue Rápido (Quickstart)

### Requisitos Previos
* Docker y Docker Compose
* Entorno Linux / WSL2 (Windows Subsystem for Linux)

### Instrucciones
1. Clona el repositorio:
   ```bash
   git clone https://github.com
   cd TU_REPOSITORIO
   ```
2. Levanta toda la infraestructura blindada en segundo plano con un solo comando:
   ```bash
   docker compose up -d --remove-orphans
   ```
3. Accede a los paneles de monitorización ingresando en tu navegador a: `http://localhost:3000` (Grafana).

---


*   **Infraestructura como Código (IaC):** Despliegue reproducible de entornos mediante Docker Compose con redes virtuales dedicadas y volúmenes persistentes para evitar la pérdida de datos.
*   **DNS Interno de Docker:** Interconexión de servicios utilizando resolución de nombres de contenedores en lugar de IPs estáticas.
*   **Monitoreo con PromQL y SQL:** Creación de consultas optimizadas para formatear datos en series temporales independientes por servidor.
*   **Gestión de Incidentes:** Simulación de picos de carga (Thresholds) y caídas de nodos para pruebas de estrés de los sistemas de alertas visuales.
